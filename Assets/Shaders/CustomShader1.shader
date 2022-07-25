Shader "Unlit/CustomShader1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Scale("Scale", float) = 1
        _Offset("Offset", float) = 0
        
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "RenderQueue" = "Transparent"
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

            float _Offset;
            float _Scale;
            
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

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = (v.uv0 + _Offset) * _Scale ;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                
                
                float xOffset = cos(i.uv.y * 6.58 * 8) * 0.01;
                float t = cos((i.uv.x + xOffset + _Time.y * 0.2) * 6.58 * 5) * 0.5 + 0.5;
                t*= (1 -i.uv.y);
                return t;
                // sample the texture
                //float color = lerp(_ColorA, _ColorB, t);
                //return color;
            }
            ENDCG
        }
    }
}
