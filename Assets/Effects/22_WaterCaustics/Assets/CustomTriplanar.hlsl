
#include <UnityShaderVariables.cginc>

//Rotate node
float2 Unity_Rotate_Degrees_float(float2 uv, float2 center, float rotation)
{
    rotation = rotation * (3.1415926f/180.0f);
    uv -= center;
    float s = sin(rotation);
    float c = cos(rotation);

    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 -1;

    uv.xy = mul(uv.xy, rMatrix);
    uv += center;

    return uv;
}

void TextureProjection_float
(
    in Texture2D tex,
    in SamplerState ss,
    in float3 position,
    in float3 normal,
    in float tile,
    in float blend,
    in float speed,
    in float rotation,
    out float4 result
)
{
    float speed_uv =  _Time.y * speed;
    float3 node_uv = position * tile;
    float3 node_blend = pow(abs(normal), blend);
    node_blend /= dot(node_blend, 1.0);
    
    float4 node_x = UNITY_SAMPLE_TEX2D(tex, Unity_Rotate_Degrees_float(node_uv.yz, 0, rotation) + speed_uv);
    float4 node_y = UNITY_SAMPLE_TEX2D(tex, Unity_Rotate_Degrees_float(node_uv.yz, 0, rotation) + speed_uv);
    float4 node_z = UNITY_SAMPLE_TEX2D(tex, Unity_Rotate_Degrees_float(node_uv.yz, 0, rotation) + speed_uv);

    result = node_x * node_blend.x + node_y * node_blend.y + node_z * node_blend.z;

}