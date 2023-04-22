Shader "YKF/5RIM"
{
    Properties
    {
        /*_Float("float",float) = 0.0
        _range("range",range(0,1)) =0.0
        _vector("vector",vector) = (1,1,1,1)
        _Color("color",color) = (0.5,0.5,0.5,0.5)*/
        _MainColor("MainColor",color) = (1,1,1,1)
        _Emiss("Emiss",float) = 1
        _RimPower("RimPower",float) = 1
        _MainTex("MainTex",2D)= "white"{}
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode",float) = 1
    }
    SubShader{
         Tags{ "Queue" = "Transparent" }
        pass{
            cull front
            zwrite on
            Colormask 0
            CGPROGRAM
            float4 _color;
            #pragma vertex vert
            #pragma fragment frag
            float4 vert(float4 vertexPos :POSITION):SV_POSITION
            {
                return UnityObjectToClipPos(vertexPos);
                }
            float4 frag(void):COLOR
            {
                return _color;
                }
            ENDCG
            }

        Pass
        {
            //Blend SrcAlpha One
            Blend SrcAlpha OneMinusSrcAlpha
            Zwrite off
            cull [_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma  fragment frag
            #include "UnityCG.cginc"

            struct appdate
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORDO;
                float3 normal_world: TEXCOORD1;
                float3 view_world :TEXCOORD2;
            };

            float4 _Color,_MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Emiss,_RimPower;
            

            v2f vert(appdate v)
            {
                v2f o;
                float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
                float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
                             //  o.pos= UnityObjectToClipPos(v.vertex);
                o.pos = pos_clip;
                o.normal_world = normalize(mul(float4(v.normal,0),unity_ObjectToWorld).xyz);
                o.view_world = normalize(_WorldSpaceCameraPos - pos_world);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.pos_uv = v.vertex.yz*_MainTex_ST.xy+ _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world =normalize(i.view_world);
                float NDotv = saturate(dot(normal_world,view_world));
                float3 color = _MainColor.rgb*_Emiss;
                float alpha = pow((1-NDotv),_RimPower);
                float4 col = tex2D(_MainTex,   i.uv)*_MainColor*_Emiss;
                float fresnel = saturate(alpha*_Emiss);
                return float4(color,alpha);
            }
            ENDCG



        }
    }
}