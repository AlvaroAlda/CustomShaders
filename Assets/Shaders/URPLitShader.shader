Shader "URP/LitShaderCustom"
{
    Properties
    {
        [Header(LightSettings)][Space(20)]
        
        _Color("Color", Color) = (1,1,1,1)
        _Ambient ("Ambient Intensity", Range(0,1)) = 1

        

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
                float4 shadowCoord : TEXCOORD1;
                float3 normals: TEXCOORD2;
                float3 wPos: TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Ambient;
            CBUFFER_END

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = TransformObjectToHClip(v.vertex.rgb);

                //Obligatory to share this info
                //For lighting purposes is obligatory to put into world coordinates
                o.normals = TransformObjectToWorldNormal(v.normals);
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.shadowCoord = GetShadowCoord(vertexInput);
                //Calculates the world pos from the vertex pos using the unity transform matrix
                o.wPos = mul(unity_ObjectToWorld, v.vertex).rgb;
                return o;
            }

            half4 frag (Interpolators i) : SV_Target
            {
               // you can find GetMainLight function at Lighting.hlsl
                Light light = GetMainLight(i.shadowCoord);
                float3 shadow = light.shadowAttenuation;
                half4 col = _Color;
                col.rgb *= shadow;
     
                return col;
                
            }
            ENDHLSL
        }

        //For URP or other SRP 
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}

    

