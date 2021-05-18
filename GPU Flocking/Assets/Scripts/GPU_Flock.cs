using UnityEngine;

public class GPU_Flock : MonoBehaviour
{
    private struct FlockUnit
    {
        public Vector3 position;
        public Vector3 forward;
        public Quaternion rotation;
        public float speed;
    }

    //one float, 2 vector3 and one vector4 with float values
    private const int FLOCK_UNIT_SIZE = (1 + 3 * 2 + 4) * sizeof(float);

    private const int THREAD_GROUPS = 256;

    [Header("Spawn Setup")]
    [SerializeField]
    private Mesh flockUnityMesh;
    [SerializeField]
    private int submeshIndex = 0;
    [SerializeField]
    private Material flockUnityMaterial;
    [SerializeField]
    private ComputeShader flockComputeShader;
    private int computeKernelIndex;
    [SerializeField]
    private int flockSize = 100;
    [SerializeField]
    private Vector3 spawnBounds;

    [Header("Flock Unit Setup")]
    [SerializeField]
    private float FOVAngle;
    [SerializeField]
    private float smoothDamp;
    [SerializeField]
    private LayerMask obstacleMask;
    [SerializeField]
    private Vector3[] directionsToCheckWhenAvoidingObstacles;

    [Header("Speed Setup")]
    [SerializeField, Range(0, 10)]
    private float _minSpeed;
    public float minSpeed { get { return _minSpeed; } }
    [SerializeField, Range(0, 10)]
    private float _maxSpeed;
    public float maxSpeed { get { return _maxSpeed; } }

    [Header("Detection Distance")]
    [SerializeField, Range(0, 10)]
    private float _cohesionDistance;
    public float cohesionDistance { get { return _cohesionDistance; } }

    [SerializeField, Range(0, 10)]
    private float _avoidanceDistance;
    public float avoidanceDistance { get { return _avoidanceDistance; } }

    [SerializeField, Range(0, 10)]
    private float _alignmentDistance;
    public float alignmentDistance { get { return _alignmentDistance; } }

    [SerializeField, Range(0, 10)]
    private float _obstacleDistance;
    public float obstacleDistance { get { return _obstacleDistance; } }

    [SerializeField, Range(0, 100)]
    private float _boundsDistance;
    public float boundsDistance { get { return _boundsDistance; } }

    [Header("Behavior Weight")]
    [SerializeField, Range(0, 10)]
    private float _cohesionWeight;
    public float cohesionWeight { get { return _cohesionWeight; } }

    [SerializeField, Range(0, 10)]
    private float _avoidanceWeight;
    public float avoidanceWeight { get { return _avoidanceWeight; } }

    [SerializeField, Range(0, 10)]
    private float _alignmentWeight;
    public float alignmentWeight { get { return _alignmentWeight; } }

    
    [SerializeField, Range(0, 10)]
    private float _boundsWeight;
    public float boundsWeight { get { return _boundsWeight; } }

    [SerializeField, Range(0, 100)]
    private float _obstacleWeight;
    public float obstacleWeight { get { return _obstacleWeight; } }

    private ComputeBuffer flockUnitBuffer;

    private void Start()
    {
        if (flockSize < 1)
            flockSize = 1;

        //FLOCK UNITY ARRAY AND BUFFER
        FlockUnit[] flockUnits = new FlockUnit[flockSize];
        for(int i = 0; i < flockSize; i++)
        {
            var randomVector = UnityEngine.Random.insideUnitSphere;
            randomVector = new Vector3(randomVector.x * spawnBounds.x, randomVector.y * spawnBounds.y, randomVector.z * spawnBounds.z);
            var spawnPosition = transform.position + randomVector;
            var rotation = Quaternion.Euler(0, UnityEngine.Random.Range(0, 360), 0);
            flockUnits[i].position = spawnPosition;
            flockUnits[i].forward = transform.forward;
            flockUnits[i].rotation = rotation;
            flockUnits[i].speed = UnityEngine.Random.Range(minSpeed, maxSpeed);
        }
        flockUnitBuffer = new ComputeBuffer(flockSize, FLOCK_UNIT_SIZE);
        flockUnitBuffer.SetData(flockUnits);

        //SEND DATA TO COMPUTE SHADER
        computeKernelIndex = flockComputeShader.FindKernel("CSMain");
        flockComputeShader.SetBuffer(computeKernelIndex, "_flockUnitBuffer", flockUnitBuffer);
        flockComputeShader.SetInt("_flockSize", flockSize);
        flockComputeShader.SetFloat("_cohesionDistance", cohesionDistance);
        flockComputeShader.SetFloat("_FOVAngle", FOVAngle);
        flockComputeShader.SetFloat("_cohesionWeight", cohesionWeight);
        flockComputeShader.SetFloat("_smoothDamp", smoothDamp);
        flockComputeShader.SetFloat("_minSpeed", minSpeed);
        flockComputeShader.SetFloat("_maxSpeed", maxSpeed);
        flockComputeShader.SetFloat("_avoidanceDistance", avoidanceDistance);
        flockComputeShader.SetFloat("_avoidanceWeight", avoidanceWeight);

        //SEND DATA TO MATERIAL
        flockUnityMaterial.SetBuffer("_flockUnitBuffer", flockUnitBuffer);
    }

    private void Update()
    {
        flockComputeShader.SetFloat("_Time", Time.deltaTime);

        //dispatch kernel
        int groups = Mathf.CeilToInt(flockSize / THREAD_GROUPS);
        flockComputeShader.Dispatch(computeKernelIndex, groups, 1, 1);
        //render
        flockUnityMaterial.SetPass(0);
        Graphics.DrawMeshInstancedProcedural(flockUnityMesh, submeshIndex, flockUnityMaterial, 
            new Bounds(transform.position, spawnBounds), flockSize);
    }

    void OnDestroy()
    {
        if (flockUnitBuffer != null)
        {
            flockUnitBuffer.Release();
            flockUnitBuffer = null;
        }
    }

}
