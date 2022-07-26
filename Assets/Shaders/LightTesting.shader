Shader "Unlit/LightTesting"
{
    Properties
    {
        [Header(Properties)][Space(20)]
        
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcBlend ("SrcFactor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("DstFactor", Float) = 1
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
        [Toggle] _ZWrite ("ZWrite", Float) = 0
        
        
        [Header(LightSettings)][Space(20)]
        
        _Gloss ("Glossines", Range(0,1)) = 1
        _Color("Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (0.5,0.5,0.5,1)
        
        [ToggleOff] _Fresnel ("Fresnel", float) = 0
         _FresnelPOW ("FresnelPOW", Range(0,1)) = 1
        [HDR] _FresnelColor("FresnelColor", Color) = (1,1,1,1)
        

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
            #include "HLSLSupport.cginc"
            
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
                float4 shadowCoord : TEXCOORD1;
                float3 normals: TEXCOORD2;
                float3 wPos: TEXCOORD3;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _FresnelColor;
            float4 _AmbientColor;
            float _Gloss;
            float _FresnelPOW;
            float _Fresnel;
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
                
                return float4(totalLight, _Color.a);
            }
            ENDHLSL
        }
        
        //FOR BUILT IN RP
         /*Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }*/
        
        //For URP or other SRP 
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
