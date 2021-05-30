/*
* Functions adapted from https://github.com/Unity-Technologies/UnityCsReference/blob/master/Runtime/Export/Math/Vector3.cs
*/
#define K_EPSILON 0.00001
#define K_EPSILON_NORMAL_SQRT 1e-15
#define PI 3.14159265359
#define RAD2DEG (180.0/PI)
#define MAX_SPEED 1e20

bool VectorEquals(float3 vec1, float3 vec2)
{
    return vec1.x == vec2.x && vec1.y == vec2.y && vec1.z == vec2.z;
}

// Returns the squared length of this vector
float SqrMagnitude(float3 vec) {
    return vec.x * vec.x + vec.y * vec.y + vec.z * vec.z;
}
// Returns the length of this vector
float Magnitude(float3 vec) {
    return sqrt(SqrMagnitude(vec));
}

// Returns the angle in degrees between /from/ and /to/. This is always the smallest
float Angle(float3 from, float3 to)
{
    // sqrt(a) * sqrt(b) = sqrt(a * b) -- valid for real numbers
    float denominator = sqrt(SqrMagnitude(from) * SqrMagnitude(to));
    if (denominator < K_EPSILON_NORMAL_SQRT)
        return 0.0;

    float dotted = clamp(dot(from, to) / denominator, -1.0, 1.0);
    return acos(dotted) * RAD2DEG;
}


// Returns this vector with a ::ref::magnitude of 1
float3 Normalize(float3 value)
{
    float mag = Magnitude(value);
    float3 ans = value / mag;
    if (mag > K_EPSILON)
    {
        return value / mag;
    }
    else
    {
        return float3(0.0, 0.0, 0.0);
    }
}

// Gradually changes a vector towards a desired goal over time.
float3 SmoothDamp(float3 current, float3 target, inout float3 currentVelocity, float smoothTime, float deltaTime)
{
    float output_x = 0.0;
    float output_y = 0.0;
    float output_z = 0.0;

    // Based on Game Programming Gems 4 Chapter 1.10
    smoothTime = max(0.0001, smoothTime);
    float omega = 2.0 / smoothTime;

    float x = omega * deltaTime;
    float exp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x);

    float change_x = current.x - target.x;
    float change_y = current.y - target.y;
    float change_z = current.z - target.z;
    float3 originalTo = target;

    // Clamp maximum speed
    float maxChange = MAX_SPEED * smoothTime;

    float maxChangeSq = maxChange * maxChange;
    float sqrmag = change_x * change_x + change_y * change_y + change_z * change_z;
    if (sqrmag > maxChangeSq)
    {
        float mag = sqrt(sqrmag);
        change_x = change_x / mag * maxChange;
        change_y = change_y / mag * maxChange;
        change_z = change_z / mag * maxChange;
    }

    target.x = current.x - change_x;
    target.y = current.y - change_y;
    target.z = current.z - change_z;

    float temp_x = (currentVelocity.x + omega * change_x) * deltaTime;
    float temp_y = (currentVelocity.y + omega * change_y) * deltaTime;
    float temp_z = (currentVelocity.z + omega * change_z) * deltaTime;

    currentVelocity.x = (currentVelocity.x - omega * temp_x) * exp;
    currentVelocity.y = (currentVelocity.y - omega * temp_y) * exp;
    currentVelocity.z = (currentVelocity.z - omega * temp_z) * exp;

    output_x = target.x + (change_x + temp_x) * exp;
    output_y = target.y + (change_y + temp_y) * exp;
    output_z = target.z + (change_z + temp_z) * exp;

    // Prevent overshooting
    float origMinusCurrent_x = originalTo.x - current.x;
    float origMinusCurrent_y = originalTo.y - current.y;
    float origMinusCurrent_z = originalTo.z - current.z;
    float outMinusOrig_x = output_x - originalTo.x;
    float outMinusOrig_y = output_y - originalTo.y;
    float outMinusOrig_z = output_z - originalTo.z;

    if (origMinusCurrent_x * outMinusOrig_x + origMinusCurrent_y * outMinusOrig_y + origMinusCurrent_z * outMinusOrig_z > 0)
    {
        output_x = originalTo.x;
        output_y = originalTo.y;
        output_z = originalTo.z;

        currentVelocity.x = (output_x - originalTo.x) / deltaTime;
        currentVelocity.y = (output_y - originalTo.y) / deltaTime;
        currentVelocity.z = (output_z - originalTo.z) / deltaTime;
    }

    return float3(output_x, output_y, output_z);
}

// the following functions were obtained from
// https://gist.github.com/aeroson/043001ca12fe29ee911e
float3 safeNormalize(float3 vec) {
    if (length(vec) < K_EPSILON_NORMAL_SQRT) {
        return float3(0, 0, 0);
    }
    else {
        return normalize(vec);
    }
}

float4 lookRotation(float3 forward, float3 up) {
    forward = safeNormalize(forward);
    float3 right = safeNormalize(cross(up, forward));
    up = cross(forward, right);

    float m00 = right.x;
    float m01 = right.y;
    float m02 = right.z;
    float m10 = up.x;
    float m11 = up.y;
    float m12 = up.z;
    float m20 = forward.x;
    float m21 = forward.y;
    float m22 = forward.z;

    float num8 = (m00 + m11) + m22;

    float4 quaternion = float4(0, 0, 0, 0);

    if (num8 > 0) {
        float num = sqrt(num8 + 1);
        quaternion.w = num * 0.5;
        num = 0.5 / num;
        quaternion.x = (m12 - m21) * num;
        quaternion.y = (m20 - m02) * num;
        quaternion.z = (m01 - m10) * num;
        return quaternion;
    }
    if ((m00 >= m11) && (m00 >= m22)) {
        float num7 = sqrt(((1 + m00) - m11) - m22);
        float num4 = 0.5 / num7;
        quaternion.x = 0.5 * num7;
        quaternion.y = (m01 + m10) * num4;
        quaternion.z = (m02 + m20) * num4;
        quaternion.w = (m12 - m21) * num4;
        return quaternion;
    }
    if (m11 > m22) {
        float num6 = sqrt(((1 + m11) - m00) - m22);
        float num3 = 0.5 / num6;
        quaternion.x = (m10 + m01) * num3;
        quaternion.y = 0.5 * num6;
        quaternion.z = (m21 + m12) * num3;
        quaternion.w = (m20 - m02) * num3;
        return quaternion;
    }
    float num5 = sqrt(((1 + m22) - m00) - m11);
    float num2 = 0.5 / num5;
    quaternion.x = (m20 + m02) * num2;
    quaternion.y = (m21 + m12) * num2;
    quaternion.z = 0.5 * num5;
    quaternion.w = (m01 - m10) * num2;
    return quaternion;
}



// the following function was obtained from
// https://pastebin.com/fAFp6NnN

float3 rotateVector(float3 vec, float4 quat) {
    float3 result = float3(0, 0, 0);
    float num12 = quat.x + quat.x;
    float num2 = quat.y + quat.y;
    float num = quat.z + quat.z;
    float num11 = quat.w * num12;
    float num10 = quat.w * num2;
    float num9 = quat.w * num;
    float num8 = quat.x * num12;
    float num7 = quat.x * num2;
    float num6 = quat.x * num;
    float num5 = quat.y * num2;
    float num4 = quat.y * num;
    float num3 = quat.z * num;
    float num15 = ((vec.x * ((1 - num5) - num3)) + (vec.y * (num7 - num9))) + (vec.z * (num6 + num10));
    float num14 = ((vec.x * (num7 + num9)) + (vec.y * ((1 - num8) - num3))) + (vec.z * (num4 - num11));
    float num13 = ((vec.x * (num6 - num10)) + (vec.y * (num4 + num11))) + (vec.z * ((1 - num8) - num5));
    result.x = num15;
    result.y = num14;
    result.z = num13;
    return result;
}