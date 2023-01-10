Shader "Unlit/SpherizeParticle"
{
    Properties
    {
      _Color("Color", Color) = (1,1,1,1)
      _Gloss ("Gloss", Range(0.001 ,5)) = 1
      _GlossStrength("GlossStrength", Range(0.001 ,20)) = 1
      _Ambient ("Ambient Amount", Range(0,5)) = 1
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

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };
            

            float4 _MainTex_ST;
            
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Ambient;
            float _Gloss;
            float _GlossStrength;
            CBUFFER_END
  
       
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2 - 1;
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 N;
                N.xy = i.uv;

                //Discard non circular coordinates
                const float r2 = dot(N.xy, N.xy);
                if (r2 > 1.0) discard;
                N.z = sqrt(1.0f - r2);

                //Compensate the view matrix due to quad constantly rotating towards it
                const float3 normal = mul((float3x3) transpose(UNITY_MATRIX_V), float3(N.x, N.y, N.z));

                //Diffuse Lighting
                const float3 light = _WorldSpaceLightPos0.xyz;
                const float3 lambertian = saturate(dot(normalize(normal), light));

                const float3 diffuseLight = lambertian * _LightColor0;

                //Specular lighting highlights
                float3 view = normalize(_WorldSpaceCameraPos - normal);
                float3 halfVector = normalize(light + view); // used in bling-phong

                //The boolean multiplication avoids strange sports from behind the light 
                float3 specular = saturate(dot(halfVector, normal)) * (lambertian > 0);
                float specularExponent = exp2(_Gloss * _GlossStrength + 1);
                specular = pow(specular, specularExponent) * _Gloss;
                specular *= _LightColor0.xyz;
                
                //Ambient
                const float3 lightAmbient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);

                //All light components
                const float3 totalLight = specular + (diffuseLight + lightAmbient * _Ambient) * _Color;
                float3 color = totalLight * i.color;
                
                return float4(color, _Color.a * i.color.a);
            }
            ENDCG
        }
    }
}




