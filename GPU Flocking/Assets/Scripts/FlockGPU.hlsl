#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	struct FlockUnit
	{
		float3 position;
		float3 forward;
		float4 rotation;
		float speed;
	};
	StructuredBuffer<FlockUnit> _flockUnitBuffer;
#endif

void ConfigureProcedural() {
#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	float3 position = _flockUnitBuffer[unity_InstanceID].position;

	unity_ObjectToWorld = 0.0;
	unity_ObjectToWorld._m03_m13_m23_m33 = float4(position, 1.0);
	unity_ObjectToWorld._m00_m11_m22 = 1.0;
#endif
}

void ShaderFunction_float(float3 In, out float3 Out) {
	Out = In;
}