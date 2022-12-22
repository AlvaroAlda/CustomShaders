Shader "URP/Diffuse"
{
    Properties
    {
        [Header(LightSettings)][Space(20)]
        _Color("Color", Color) = (1,1,1,1)
        _BaseMap_ST("BaseMapST", float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Geometry" 
            "RenderPipeline"="UniversalRenderPipeline"
        }

        //Blend[_SrcBlend][_DstBlend]
        //ZWrite[_ZWrite]
        //Cull[_Cull]
        
        LOD 100

        Pass
        {
            //For URP only
            Tags 
            { 
               "LightMode"="UniversalForward"
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            //For URP only
            #pragma multi_compile _ _MAIN_LIGHT_SHADOW
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

     
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            

            float3 LambertShading(float3 colorRefl, float lightInt, float3 normal, float3 lightDir)
            {
                return saturate(colorRefl * lightDir * max(0, dot(normal, lightDir)));
            }
            
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
                float3 normals: TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Ambient;
            float _BaseMap_ST;
            CBUFFER_END

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex.rgb);

                o.uv = v.uv;
                
                //Obligatory to share this info
                //For lighting purposes is obligatory to put into world coordinates
                o.normals = normalize(mul(unity_ObjectToWorld, float4(v.normals,0))).xyz;
                
                return o;
            }

            half4 frag (Interpolators i) : SV_Target
            {
               // you can find GetMainLight function at Lighting.hlsl
                
                Light light = GetMainLight();
                float4 col = (light.color, 1);
                float3 normal = i.normals;
                float3 lightDir = normalize(light.direction);
                float3 colorRefl = light.color.rgb;
                float3 diffuse = LambertShading(colorRefl, 1, normal, lightDir);
                col.rgb *= diffuse;
                return col;
                
            }
            ENDHLSL
        }

        //For URP or other SRP 
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}

    

