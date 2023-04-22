Shader "YKF/02texturing"
{
    Properties
    {
        /*_Float("float",float) = 0.0
        _range("range",range(0,1)) =0.0
        _vector("vector",vector) = (1,1,1,1)
        _Color("color",color) = (0.5,0.5,0.5,0.5)*/
        _MainTex("MainTex",2D)= "blace"{}
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("CullMode",float) = 1
    }
    SubShader
    {

        Pass
        {
            cull [_CullMode]
            CGPROGRAM
            #pragma vertex vert
            #pragma  fragment frag
            //#include "UnityCG.cginc"

            struct appdate
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORDO;
                float2 pos_uv : TEXCOORD1;
            };

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdate v)
            {
                v2f o;
                float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world);
                float4 pos_clip = mul(UNITY_MATRIX_P, pos_view);
                o.pos = pos_clip;
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.pos_uv = v.vertex.yz*_MainTex_ST.xy+ _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float4 col = tex2D(_MainTex, i.pos_uv);
                return col;
            }
            ENDCG



        }
    }
}