#include "Utilities.cginc"

#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	struct FlockUnit
	{
		float3 flockPosition;
		float3 position;
		float3 rotation;
		float speed;
	};
	StructuredBuffer<FlockUnit> _flockUnitBuffer;
#endif

void ConfigureProcedural() {

}

void ShaderFunction_float(float3 In, out float3 Out) {
#if defined(UNITY_PROCEDURAL_INSTANCING_ENABLED)
	float3 position = _flockUnitBuffer[unity_InstanceID].position;
	float3 rotation = _flockUnitBuffer[unity_InstanceID].rotation;

	float4 quat = lookRotation(rotation, float3(0.0, 1.0, 0.0));
	float3 rotatedPos = rotateVector(In, quat);

	position += rotatedPos;

	In += position;
#endif
	Out = In;
}