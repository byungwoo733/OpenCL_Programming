// Clothes Simulation using Bullet Physics SDK  
// LinkLengthRatio

for each time step
    Preapare links
    for each velocity iteration
        for each link in mesh
            (velocity0, inverseMass0) = linkStart
            (velocity1, inverseMASS1) = linkEnd
            float3 velocityDifference = velocity1 - velocity0;
            float velAlongLink = dot( linkVector, velocityDifference );
            float correction = -velAlongLink*linkLengthRatio*k;
            velocity0 -= linkVector*k*inverseMass0;
            velocity1 += linkVector*k*inverseMass1;

    Estimate position corrections from velocities

    for each position iteration
        for each link in mesh
            (position0, inverseMass0) = linkStart
            (position1, inverseMass1) = linkEnd
            float3 vectorLength = positional1 - positional0;
            float length = dot(vectorLength, vectorLength);
            float k = ( (restLengthSquared - len) /
                        (massLSC*(restLengthSquared+len)))*kst;
            position0 -= vectorLength * (k*inverseMass0);
            posiiton1 += vectorLength * (k*inverseMass1);

// Simulation Running in CPU
// (ex)
void btSoftBody::PSolve_Links(
    btSoftBody* psb,
    btScalar kst,
    btScalar ti)
{

    for(int i=0, ni = psb->m_links.size(); i < ni; ++i)
    {
        Link &1=psb->m_links[i];
        if(l.m_c0>0) {
            Node &a = *l.m_normal[0];
            Node &b = *l.m_normal[1];
            const btVector3 del = b.m_position - a.m_position;
            const btScalar len = del.length2();
            const btScalar k =
                ((l.m_cl - len)/(l.m_c0 * (l.m_cl + len)))*
                                              simulationConstant;
            a.m_x -= del*(k*a.m_inverseMass);
            b.m_x += del*(k*b.m_inverseMass);
        }
    }
}

//-------------------------------------
// Needed Changes For Basic GPU Running

for each link:
    color = 0

// (Color) Connected Other Link One point decision of Link Connected Two Points 
color = next link
linkBatch = color

// callbck solveConstraints
for(int iteration = 0;
    iteration < m_numberOfPositionIterations;
    ++iteration ) {
    for( int i = 0;
            i < m_linkData.m_batchStartLengths.size();
            ++i ) {
            int startLink = m_linkData.m_batchStartLengths[i].start;
            int numLinks = m_linkData.m_batchStartLengths[i].length;

            solveLinkForPosition( StartLink, numLinks, kst, ti);
    }
// solveLinksForPosition
void btOpenCLSoftBodySolver::solveLinksForPosition(
    int startLink,
    int numLinks,
    float kst,
    float ti)
{
    cl_int ciErrNum;
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        0,
        sizeof(int),
        &startLink);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        1,
        sizeof(int),
        &numLink);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        2,
        sizeof(float),
        &kst);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        3,
        sizeof(float),
        &ti);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        4,
        sizeof(cl_mem),
        &m_linkData.m_clLinks.m_buffer);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        5,
        sizeof(cl_mem),
        &m_linkData.m_clLinksMassLSC.m_buffer);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        6,
        sizeof(cl_mem),
        &m_linkData.m_clLinksRestLengthSqaured.m_buffer);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        7,
        sizeof(cl_mem),
        &m_vertexData.m_clVertexInverseMass.m_buffer);
    ciErrNum = clSetKernelArg(
        solvePositonsFromLinksKernel,
        8,
        sizeof(cl_mem),
        &m_vertexData.m_clVertexPosiiton.m_buffer);

    size_t numWorkItems = workGroupSize*
        ((numLinks + (workGroupSize-1)) / workGroupSize);
    ciErrNum = clEnqueueNDRangeKernel(
        m_cqCommandQue,
        solvePositionsFromLinksKernel,
        1,
        NULL,
        &numWorkGroupSize,0,0,0);
    if( ciErrNum!= CL_SUCCESS ) {
        btAssert( 0 &&
        "enqueueNDRangeKernel(solvePositonsFromLinksKernel)");
    }
} // solveLinksForPosition

// GPU running in Compiled OpenCL Kernel
__kernel void
SolvePositionsFromLinksKernel(
    const int startLink,
    const int numLinks,
    const float kst,
    const float ti,
    __global int2  * g_linksVertexIndices,
    __global float * g_linksMassLSC,
    __global float * g_linksRestLengthSquared,
    __global float * g_verticesInverseMass,
    __global float * g_vertexPositions)
{
    int linkID = get_global_id(0) + startLink;
    if( get_global_id(0) < numLinks) {
        float massLSC = g_linksMassLSC[linkID];
        float restlengthSquared = g_linksRestLengthSquared[linkID];

        if( massLSC > 0.0f ) {
            int2 nodeIndices = g_linksVertexIndices[linkID];
            int node0 = nodeIndices.x;
            int node1 = nodeIndices.y;

            float3 position0 = g_vertexPositions[node0].xyz;
            float3 position1 = g_vertexPositions[node1].xyz;

            float inverseMass0 = g_verticesInverseMass[node0];
            float inverseMass0 = g_verticesInverseMass[node1];

            float3 del = position1 - position0;
            float len = dot(del, del);
            float k = ((restLengthSquared - len)/(massLSC*(restLengthSquared_len)))*kst;

            position0 = position0 - del*(k*inverseMass0);
            position1 = position1 + del*(k*inverseMass1);

            g_vertexPositions[node0] = (float4)(position0, 0.f);
            g_vertexPositions[node1] = (float4)(position1, 0.f);

        }
    }
}

// Two Level Collectivization
__kernel void
SolvePositionsFromLinksKernel(
    const int startLink,
    const int numLinks,
    const float kst,
    const float ti,
    __global int2  * g_linksVertexIndices,
    __global float * g_linkssMassLSC,
    __global float * g_linksRestLengthSquared,
    __global float * g_verticesInverseMass,
    __global float4 * g_vertexPositions)

{
    for( batch = 0; batch < numLocalBatches; ++batch )
    {
        // Assume that the links within the group are arranged in the order of the local groups.
        int linkID = get_global_id(0)*batch;

        float massLSC = g_linksMassLSC[linkID];
        float restLengthSquared = g_linksRestLengthSquared[linkID];
        
        if( massLSC > 0.0f ) {
            int2 nodeIndices = g_linksVertexIndices[linkID];
            int node0 = nodeIndices.x;
            int node1 = nodeIndices.y;

            float3 position0 = g_vertexPositions[node0].xyz;
            float3 position1 = g_vertexPositions[node1].xyz;
            float inverseMass0 = g_verticesInverseMass[node0];
            float inverseMass1 = g_verticesInverseMass[node1];

            float3 del = position1 - position0;
            float len = dot(del, del);
            float k = ((restLengthSquared - len)/(massLSC*(restLengthSquared+len)))*kst;
            position0 = position0 - del*(k*inverseMass0);
            position1 = position1 - del*(k*inverseMass1);

            g_vertexPositions[node0] = (float4) (position0, 0.f);
            g_vertexPositions[node1] = (float4) (position0, 0.f);

        }

        barrier(CLK_GLOBAL_MEM_FENCE);
    }
}

//==============================================
// Optimization & Local Memory about SIMD Unit
for each batch of work-groups:
    for each batch of links within the chunk:
        process link
        barrier;
    
// Algorism
for each batch of wavefronts:
    load all vertex data needed by the chunk
    for each batch of links within the wavefront
        process link using vertices in local memory
        local fence
    store updated vertex data back to global memory

// Fence use & Wavefront based Kernel:
__kernel void
SolvePositionsFromLinksKernel(
    const int startWaveInBatch,
    const int numWaves,
    const float kst,
    const float ti,
    __global int2 * g_wavefrontBatchCountsVertexCounts,
    __global int * g_vertexAddressesPerWavefront,
    __global int2  * g_linksVertexIndices,
    __global float * g_linksMassLSC,
    __global float * g_linksRestLengthSquared,
    __global float * g_verticesInverseMass,
    __global float4 * g_vertexPositions,
    __local int2 *wavefrontBatchCountsVertexCounts,
    __local float4 *vertexPositionSharedData,
    __local float *vertexInverseMassSharedData)
{
    const int laneInWavefront = (get_global_id(0) & (WAVEFRONT_SIZE-1));
    const int wavefront = startWaveInBatch + (get_global_id(0) / WAVEFRONT_SIZE);
    const int firstWavefrontInBlock = startWaveInBatch +
        get_group_id(0) * WAVEFRONT_BLOCK_MULTIPILER;
    const int localWavefront = wavefront - firstWavefrontInBlock;

    // Don't do it for "wavefronts" that are finally out of bounds (but included in the multiplier).
    if( wavefront < (startWaveInBatch + numWaves) ) {
         // Load the group recall for the wavefront.
         // Don't do it for "wavefronts" that are finally out of bounds (but included in the multiplier).
        if( laneInWavefront == 0) {
            int2 batchesAndVertexCountsWithinWavefront =
                g_wavefrontBatchCountsVertexCounts[wavefront];
            wavefrontBatchCountsVertexCounts[localWavefront] =
                batchesAndVertexCountsWithinWavefront;
        }

        mem_fence(CLK_LOCAL_MEM_FENCE);

        int2 batchesAndVerticesWithinWavefront =
            wavefrontBatchCountsVertexCounts[localWavefront];
        int batchesWithinWavefront = batchesAndVerticesWithinWavefront.x;
        int verticesUsedByWave = batchesAndVerticesWithinWavefront.y;
    // Load the points corresponding to the wavefront.
    for( int vertex = laneInWavefront;
         vertex < verticesUsedByWave;
         vertex+=WAVEFRONT_SIZE ) {
    int vertexAddress = g_vertexAddressesPerWavefront[
         wavefront*MAX_NUM_VERTICES_PER_WAVE + vertex];
    
    vertexPositionSharedData[localWavefront*
              MAX_NUM_VERTICES_PER_WAVE + vertex] =
        g_vertexPositions[vertexAddress];
            vertexInverseMassSharedData[localWavefront*
            MAX_NUM_VERTICES_PER_WAVE + vertex] =
        g_verticesInverseMass[vertexAddress];
    }
    mem_fence(CLK_LOCAL_MEM_FENCE);
    // Unpacking each group in the LDS executes a loop.
    int baseDataLocationForWave = WAVEFRONT_SIZE * wavefront *
    MAX_BATCHES_PER_WAVE;

    // for( int batch = 0; batch < batchesWithinWavefront; ++batch )
    int batch = 0;
    do {
        int baseDataLocation = baseDataLocationForWave + WAVEFRONT_SIZE * batch;
        int locationOfValue = baseDataLocation + laneInWavefront;

        // The following memory loads must be completely linear with respect to the wavefront.
        int2 localVertexIndices = g_linksVertexIndices[locationOfValue];
        float massLSC = g_linkMassLSC[LocationOfValue];
        float restLengthSquared = g_linksRestLengthSquared[locationOfValue];

        // Based on the number of logical wavefronts in the block and the loaded index, we get the address of the points in the LDS.
        int vertexAddress0 = MAX_NUM_VERTICES_PER_WAVE *
                             localWavefront + localVertexIndices.x;
        int vertexAddress1 = MAX_NUM_VERTICES_PER_WAVE * localWavefront +
                             localVertexIndices.y;
        
        float4 position0 = vertexPositionSharedData[vertexAddress0];
        float4 position1 = vertexPositionSharedData[vertexAddress0];
        float inverseMass0 = vertexInverseMassSharedData[vertexAddress0];
        float inverseMass0 = vertexInverseMassSharedData[vertexAddress1];

        float4 del = position1 - position0;
        float len = mydot3(del, del);

        float k = 0;
        if( massLSC > 0.0f ) {
            k = ((restLengthSquared - len)/(massLSC*(RESTlENGTHsQUARED+LEN)))*kst;
        }

        position0 = position0 - del*(k*inverseMass0);
        position0 = position1 - del*(k*inverseMass1);

        // Forces the compiler not to change the order of memory operations at will.
        mem_fence(CLK_LOCAL_MEM_FENCE);

        ++batch;
    } while( batch < batchesWithinWavefront );

    // Updates the global memory points corresponding to the wavefront.
    for( int vertex = laneInWavefront;
         vertex < verticesUsedByWave;
         vertex+=WAVEFRONT_SIZE ) {
    int vertexAddress = g_vertexAddressesPerWavefront[wavefront*
        MAX_NUM_VERTICES_PER_WAVE + vertex];
    g_vertexPositions[vertexAddress] =
        (float4)(vertexPositionSharedData[localWavefront*
        MAX_NUM_VERTICES_PER_WAVE + vertex].xyz, 0.f);
        }
    }

}

//============================================
// Add OpenGL interoperability 
// Buffer & VBO Handle Creation

struct vertex_struct
{
    float pos[3];
    float normal[3];
    float texcoord[2];
};

vertex_struct* cpu_buffer = new . . .
GLuint clothVBO;

// VBO Creation
glGenBuffers(1, &clothVBO);
glBindBuffer(GL_ARRAY_BUFFER, clothVBO);
// Initial upload is performed to check whether a buffer exists in the device.
// When OpenCL allows VBO to be used. It is important to do this.
glBufferData(GL_ARRAY_BUFFER, sizeof(vertex_struct)*width*height,
&(cpu_buffer[0]), GL_DYNAMIC_DRAW);
glBindBuffer(GL_ARRAY_BUFFER, 0);

// VBO Vertex Data Source uses:
// Makes vertex arrays, normal arrays, and texture arrays available for drawing.
glBindBuffer(GL_ARRAY_BUFFER, clothVBO);
glEnableClientState(GL_VERTEX_ARRAY);
glEnableClientState(GL_NORMAL_ARRAY);
glEnableClientState(GL_TEXTURE_COORD_ARRAY);
glBindTexture(GL_TEXTURE_2D, texture);

// Set and draw the state of the vertex buffer
glVertexPointer(
    3,
    GL_FLOAT,
    sizeof(vertex_struct),
    (const GLvoid *)0 );

glNormalPointer(
    GL_FLOAT,
    sizeof(vertex_struct),
    (const GLvoid *)(sizeof(float)*3) );

glTexCoordPointer(
    2,
    GL_FLOAT,
    sizeof(vertex_struct),
    (const GLvoid *)(sizeof(float)*6) );

glDrawElements(
    GL_TRIANGLES,
    (height-1 )*(width-1)*3*2,
    GL_UNSIGNED_INT,
    indices);

// Summary Code
glDisableClientState(GL_NORMAL_ARRAY);
glDisableClientState(GL_NORMAL_ARRAY);
glDisableClientState(GL_NORMAL_ARRAY);
glBindTexture(GL_TEXTURE_2D, 0);
glBindBuffer(GL_ARRAY_BUFFER, 0);

//-------------------------
clBuffer = clCreateFromGLBuffer(
    m_context,
    CL_MEM_WRITE_ONLY,
    clothVBO,
    &ciErrNum);

clEnqueueAcquireGLObjects(m_cqCommandQue, 1, &clBuffer, 0, 0, NULL);

clEnqueueReleaseGLObjects(m_cqCommandQue, 1, &clBuffer, 0, 0, 0);