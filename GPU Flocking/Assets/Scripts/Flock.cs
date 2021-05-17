using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Flock : MonoBehaviour
{
    [Header("Spawn Setup")]
    [SerializeField]
    private FlockUnit flockUnityPrefab;
    [SerializeField]
    private int flockSize;
    [SerializeField]
    private Vector3 spawnBounds;

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


    public FlockUnit[] allUnits { get; set; }

    private void Start()
    {
        GenerateUnits();
    }

    private void Update()
    {
        for(int i = 0; i < allUnits.Length; i++)
        {
            allUnits[i].MoveUnit();
        }
    }

    private void GenerateUnits()
    {
        allUnits = new FlockUnit[flockSize];
        for(int i = 0;  i < flockSize; i++)
        {
            var randomVector = UnityEngine.Random.insideUnitSphere;
            randomVector = new Vector3(randomVector.x * spawnBounds.x, randomVector.y * spawnBounds.y, randomVector.z * spawnBounds.z);
            var spawnPosition = transform.position + randomVector;
            var rotation = Quaternion.Euler(0, UnityEngine.Random.Range(0, 360), 0);
            allUnits[i] = Instantiate(flockUnityPrefab, spawnPosition, rotation);
            allUnits[i].AssignFlock(this);
            allUnits[i].InitializeSpeed(UnityEngine.Random.Range(minSpeed, maxSpeed));
        }
    }
}
