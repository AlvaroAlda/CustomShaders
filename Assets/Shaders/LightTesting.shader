Shader "Unlit/LightTesting"
{
    Properties
    {
        _Gloss ("Glossines", Range(0,1)) = 1
        _Color("Color", Color) = (1,1,1,1)
        _AmbientColor("Color", Color) = (0.5,0.5,0.5,1)
        
         _FresnelPOW ("FresnelPOW", Range(0,1)) = 1
        [HDR] _FresnelColor("FresnelColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals: NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normals: TEXCOORD1;
                float3 wPos: TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _FresnelColor;
            float4 _AmbientColor;
            float _Gloss;
            float _FresnelPOW;
            CBUFFER_END

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //Obligatory to share this info
                //For lighting purposes is obligatory to put into world coordinates
                o.normals = UnityObjectToWorldNormal(v.normals);

                //Calculates the world pos from the vertex pos using the unity transform matrix
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                //Diffuse lighting LAMBERT calculations
                float3 normal = normalize(i.normals);
                float3 light = _WorldSpaceLightPos0.xyz;
                float3 lambertian = saturate(dot(normal, light));
                float3 diffuseLight = lambertian * _LightColor0;

                //Specular lighting highlights
                //Camera position, get the view vector (from camera to the fragment)
                float3 view = normalize(_WorldSpaceCameraPos - i.wPos);
                //float3 reflection = reflect(-light, normal); // used in phong
                float3 halfVector = normalize(light + view); // used in bling-phong

                //The boolean multiplication avoids strange sports from behind the light 
                float3 specular = saturate(dot(halfVector, normal)) * (lambertian > 0);

                float specularExponent = exp2(_Gloss * 11 + 1);
                specular = pow(specular, specularExponent) * _Gloss;
                specular *= _LightColor0.xyz;

                //Fresnel
                float fresnel = (1-dot(view, normal)) * ((cos(_Time.y * 4))* 0.5 + 0.5);
                float fresnelExponent = exp2(_FresnelPOW * 3);
                fresnel = pow(fresnel, fresnelExponent);

                float3 totalLight = (specular + (diffuseLight + _AmbientColor)* _Color);
                
                return float4(totalLight + fresnel * _FresnelColor, 1);
            }
            ENDCG
        }
    }
}
