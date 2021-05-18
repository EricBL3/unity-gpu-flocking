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