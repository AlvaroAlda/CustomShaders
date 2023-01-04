Shader "Unlit/SpherizeParticle"
{
    Properties
    {
      _Color("Color", Color) = (1,1,1,1)
      _Gloss ("Gloss", Range(0.001 ,5)) = 1
      _GlossStrength("GlossStrength", Range(0.001 ,1)) = 1
      _Ambient ("Ambient Amount", Range(0,1)) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wPos: TEXCOORD3;
            };

            float4 _MainTex_ST;
            float4 _Color;
            
            float _Ambient;
            float _Gloss;
            float _GlossStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1;
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
   
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N;
                N.xy = i.uv;

                //Discard non circular coordinates
                float r2 = dot(N.xy, N.xy);
                if (r2 > 1.0) discard;
                N.z = sqrt(1.0f - r2);

                //Diffuse Lighting
                float3 normal = float3(N.x, N.y, -N.z);
                float3 light = _WorldSpaceLightPos0.xyz;
                float3 lambertian = saturate(dot(normal, light));
                
                float3 diffuseLight = lambertian * _LightColor0;

                //Specular lighting highlights
                float3 specular = pow(diffuseLight, _Gloss * 30) * _GlossStrength;
                
                half3 lightAmbient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                float3 totalLight = (specular + (diffuseLight + lightAmbient * _Ambient) * _Color);
                
                return float4(totalLight, _Color.a);
            }
            ENDCG
        }
    }
}
