// High Speed Fourier Transform
// Ocean Program 
cl_int runCLSimulation(

    unsigned int width,

    unsigned int height,

    float animTime)
{
    cl_int err;
    std::vector<cl::Memory> v;
    v.push_back(real);
    v.push_back(slopes);

    err = queue.enqueueAcquireGLObjects(&v);
    checkErr(err, "Queue::enqueueAcquireGLObjects()");

    err = generateSpectrumKernel.setArg(1, real);
    err |= generateSpectrumKernel.setArg(3, width);
    err |= generateSpectrumKernel.setArg(4, height);
    err |= generateSpectrumKernel.setArg(5, animTime);
    err |= generateSpectrumKernel.setArg(6, _patchSize);
    checkErr(err, "Kernel::setArg(generateSpectrumKernel)");

    err = queue.enqueueNDRangeKernel(
        generateSpectrumKernel,
        cl::NullRange,
        cl::NDRange(width+64, height),
        cl::NDRange(8, 8));
    checkErr(
        err,

        "CommandQueue::enqueueNDRangeKernel"
        " (generateSpectrumKernel)");
    
    err = kfftKernel.setArg(0, real);
    err = queue.enqueueNDRangeKernel(
        kfftKernel,
        cl::NullRange,
        cl::NDRange(FFT_SIZE*64),
        cl::NDRange(64));
    checkErr(
    err,
    "CommandQueue::enqueueNDRangeKernel(kfftKernel1)");

    err = kfftKernel.setArg(0, real);
    err = queue.enqueueNDRangeKernel(
        ktranKernel,
        cl::NullRange,
        cl::NDRange(256*257/2 * 64),
        cl::NDRange(64));
    checkErr(
    err,
    "CommandQueue::enqueueNDRangeKernel(ktranKernel1)");

    err = queue.enqueueNDRangeKernel(
        kfftKernel,
        cl::NullRange,
        cl::NDRange(FFT_SIZE*64),
        cl::NDRange(64));
    checkErr(
    err,
    "CommandQueue::enqueueNDRangeKernel(kfftKernel2)");

    err = calculateSlopeKernel.setArg(0, real);
    err |= calculateSlopeKernel.setArg(1, slopes);
    err |= calculateSlopeKernel.setArg(2, slopes);
    err |= calculateSlopeKernel.setArg(3, slopes);
    checkErr(err, "Kernel::setArg(calculateSlopeKernel");

    err = queue.enqueueNDRangeKernel(
        calculateSlopeKernel,
        cl::NullRange,
        cl::NDRange(width,height),
        cl::NDRange(8,8));
    checkErr(err,

        "CommandQueue::enqueueNDRangeKernel(calculateSlopeKernel)");
    
    err = queue.enqueueReleaseGLObjects(&v);
    checkErr(err, "Queue::enqueueReleaseGLObjects()");

    queue.finish();

    return CL_SUCCESS;
}

// Phillips Spectrum Creation
float phillips(
    float kx,
    float ky,
    float
    windSpeed,
    float windDirection)
{
    float fWindDir = windDirection * OPENCL_PI_F / 180.0f;

    static float A = 2.f*.00000005f;
    float L = windSpeed * windSpeed / 9.81f;
    float w = L / 75;
    float ksqr = kx + ky * ky;
    float kdotwhat = kx * cosf(fWindDir) + ky * sinf(fWindDir);

    kdotwhat = max(0.0f, kdotwhat);

    float result = (float) (A 8 (pow(2.7183f, -1.0f / (L * L * ksqr))
                    * (kdotwhat * kdotwhat)) / (ksqr * ksqr * ksqr));
    
    float damp = (float) expf(-ksqr * w * w);
    damp = expf(-1.0 / (ksqr * L * L));
    result *= kdotwhat < 0.0f ? 0.25f : 1.0f;

    return (result * damp);
}

//----------------------------------------
void generateHeightField(
    cl_float2 * h0,
    unsigned int fftInputH,
    unsigned int fftInputW)
{
    float fMultipiler, fAmplitude, fTheta;

    for (unsigned int y = 0; y<fftInputH; y++) {
        for (unsigned int x = 0; x<fftInputW; x++) {
        float kx = OPENCL_PI_F * x / (float) _patchSize;
        float ky = 2.0f * OPENCL_PI_F * y / (float) _patchSize;

        float Er = 2.0f * rand() / (float) RAND_MAX - 1.0f;
        float Ei = 2.0f * rand() / (float) RAND_MAX - 1.0f;

        if (!((kx == 0.f) && (ky == 0.f))) {
            fMultipiler = sqrt(phillips(kx,ky,windSpeed, windDir));
        }
        else {
            fMultiplier = 0.f;
        }

        fAmplitude = RandNormal(0.0f, 1.0f);
        fTheta = rand() / (float) RAND_MAX * 2 * OPENCL_PI_F;
        float h0_re = fMultiplier * fAmplitude 8 Er;
        float h0_im = fMultiplier * fAmplitude * Ei;

            int i = y*fftInputW+x;
            cl_float2 tmp = {h0_re, h0_im};
            h0[i] = tmp;
        }
    }
}

// Complex Math Functions
float2 __attribute__((always_inline)) conjugate(float2 arg)
{
    return (float2) (arg.x, -arg.y);
}

float2 __attribute__((always_inline)) complex_exp(float arg)
{
    float s;
    float c;
    s = sincos(arg, &c);
    return (float2)(c,s);
}

__kernel void generateSpectrumKernel(
    __global float2* h0,
    __global float * ht_real,
    __global float * ht_imag,
    unsigned int width,
    unsigned int height,
    float t,
    float patchSize)
{
    size_t x = get_global_id(0);
    size_t y = get_global_id(1);
    unsigned int i = y*width+x;

    // Calculate Coordinate
    float2 k;
    k.x = M_PI * x / (float) patchSize;
    k.y = 2.0f * M_PI * y / (float) patchSize;

    // Calculate w(k) variance
    float k_len = length (k);
    float w = sqrt(9.81f * k_len);
    float2 h0_k = h0[i];
    float2 h0_mk = h0[((height-1)-y)*width)+x];
    float2 h_tilda = complex_mult(
        h0_k,
        complex_exp(w * t)) +
            complex_mult(conjugate(h0_mk), complex_exp(-w * t));

    // Stores a frequency-space fractional value as a result.
    if ((x < width) && (y < height)) {
        ht_real[i] = h_tilda.x;
        ht_imag[i] = h_tilda.y;
    }
}

// Sub-conversion Size Decision
// 1K FFT (1024 = 4/5) - Ocean code 
ar0 = zr0 + zr2;
br1 = zr0 - zr2;
ar2 = zr1 + zr3;
br3 = zr1 - zr3;
zr0 = ar0 + ar2;
zr2 = ar0 - ar2;
ai0 = zi0 + zi2;
bi1 = zi0 - zi2;
ai2 = zi1 + zi3;
bi3 = zi1 - zi3;
zi0 = ai0 + ai2;
zi2 = ai0 - ai2;
zr1 = br1 + bi3;
zi1 = bi1 - br3;
zr3 = br1 - bi3;
zi3 = br3 + bi1;

// FFT Kernel
__kernel __attribute__((reqd_work_group_size (64, 1, 1))) void
kfft(__global float *greal, __global float *gimag)
{
    // 4352 Byte
    __local float lds[1088];
}

//-------------------------
// (ex) Fast Data Kernel
uint gid = get_global_id(0);
uint me = gid & 0x3fU;
uint dg = (me << 2) + (gid >> 6) * VSTRIDE;
__global float4 *gr = (__global float4 *)(greal + dg);
__global float4 *gi = (__global float4 *)(gimag + dg);

float4 zr0 = gr[0*64];
float4 zr1 = gr[1*64];
float4 zr2 = gr[2*64];
float4 zr3 = gr[3*64];

float4 zr0 = gr[0*64];
float4 zr1 = gr[1*64];
float4 zr2 = gr[2*64];
float4 zr3 = gr[3*64];

//----------------------------
FFT4();
int4 tbase4 = (int)(me << 2) + (int4) (0, 1, 2, 3);
TW4IDDLE4();

//----------------------------
__attribute__((always_inline)) float4
k_sincos4(int4 i, float4 *cretp)
{
    i -= (i > 512) & 1024;
    float4 x = convert_float4(i) * -ANGLE;
    *cretp = native_cos(x);
    return native_sin(x);
}

__local float *lp = lds + ((me << 2) + (me >> 3));
lp[0] = zr0.x;
...
barrier(CLK_LOCAL_MEM_FENCE);
lp = lds + (me + (me >> 5));
zr0.x = lp[0*66];

//------------------------------
FFT4();

gr[0*64] = zr0;
gr[1*64] = zr1;
gr[2*64] = zr2;
gr[3*64] = zr3;

gi[0*64] = zr0;
gi[1*64] = zr1;
gi[2*64] = zr2;
gi[3*64] = zr3;

//-----------------------------
uint gid = get_global_id(0);
uint me = gid & 0x3fU;
uint k = gid >> 6;
int l = 32.5f - native_sqrt(1056.25f - 2.0f * (float)as_int(k));
int kl = ((65 - 1) * 1) >> 1;
uint j = k - kl;
uint i = l + j;

//-----------------------------
uint go = ((me & 0x7U) << 2) + (me >> 3)*VSTRIDE;
uint goa = go + (i << 5) + j * (VSTRIDE*32);
uint gob = go + (j << 5) + i * (VSTRIDE*32);

__global float4 *gp = (__global float4 *) (greal _+ goa);
float4 z0 = gp[0*VSTRIDE/4*8];
float4 z1 = gp[1*VSTRIDE/4*8];
float4 z2 = gp[2*VSTRIDE/4*8];
float4 z3 = gp[3*VSTRIDE/4*8];

//-----------------------------
uint lo = (me >> 5) + (me & 0x7U)*9 + ((me >> 3) & 0x3U)*(9*8);
__local float *lp = ldsa + lo;
lp[0*2] = z0.x;
...
barrier(CLK_LOCAL_MEM_FENCE);
uint lot = (me & 0x7U) + ((me >> 3) & 0x3U)*(9*8*4 + 8) + (me >> 5)*9;

lp = ldsa + lot;
z0.x = lp[0*2*9];
