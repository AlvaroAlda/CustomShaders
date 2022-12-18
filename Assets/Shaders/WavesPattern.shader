Shader "Unlit/CustomShader1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _WaveAmplitude ("Wave Amplitude", float) = 0.001
        
        _Scale("Scale", float) = 1
        _Offset("Offset", float) = 0
        
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderQueue" = "Geometry"
             }
        LOD 100

        Pass
        {
            Cull Off
            //Blend One One // Additive
            //Blend DstColor Zero // Multiply
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _ColorA;
            float4 _ColorB;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD0;
                float2 uv: TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            float _Offset;
            float _Scale;
            float _WaveAmplitude;
            CBUFFER_END
            
              float getWave (float2 uv)
            {
                float2 uvsCentered = uv * 2 - 1;
                float radialDistance = length(uvsCentered);

                float wave = cos((radialDistance -_Time.y * 0.1) * 6.58 * 5) * 0.5 + 0.5;
                wave *= 1 -radialDistance;
                return wave;
            }
            
            Interpolators vert (MeshData v)
            {
                Interpolators o;

                o.uv = (v.uv0 + _Offset) * _Scale ;
                float wave = getWave(o.uv);
                v.vertex.z = (wave + _Offset) *_WaveAmplitude;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return getWave(i.uv);
            }

          
            
            ENDCG
        }
    }
}
