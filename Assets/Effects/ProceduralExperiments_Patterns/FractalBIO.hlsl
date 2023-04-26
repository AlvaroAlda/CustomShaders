// Get 2D rotation matrix given angle (radians).

// c, -s, s, c = clockwise.
// c, s, -s, c = counterclockwise.
float2x2 Get2DRotationMatrix(float angle)
{
    float c = cos(angle);
    float s = sin(angle);

    return float2x2(c, -s, s, c);
}

// Output this function directly (default values only for reference).

void GetAnimatedOrganicFractal_float(
    float scale,
    float scaleMultStep,
    float rotationStep,
    float iterations,
    float2 uv,
    float uvAnimationSpeed,
    float rippleStrength,
    float rippleMaxFrequency,
    float rippleSpeed,
    float brightness,
    float time,
    out float output)
{
    // Remap to [-1.0, 1.0].

    uv = float2(uv - 0.5) * 2.0;

    float2 n, q;
    float invertedRadialGradient = pow(length(uv), 2.0);
    
    float2x2 rotationMatrix = Get2DRotationMatrix(rotationStep);

    float t = time;
    float uvTime = t * uvAnimationSpeed;

    // Ripples can be pre-calculated and passed from outside.
    // They don't need to be here in this function.

    float ripples = sin((t * rippleSpeed) - (invertedRadialGradient * rippleMaxFrequency)) * rippleStrength;

    for (int i = 0; i < iterations; i++)
    {
        uv = mul(rotationMatrix, uv);
        n = mul(rotationMatrix, n);

        float2 animatedUV = (uv * scale) + uvTime;

        q = animatedUV + ripples + i + n;
        output += dot(cos(q) / scale, float2(1.0, 1.0) * brightness);

        n -= sin(q);

        scale *= scaleMultStep;
    }
}