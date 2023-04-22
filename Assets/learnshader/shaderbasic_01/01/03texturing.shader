Shader "YKF/03texturing"
{
    Properties
    {
        /*_Float("float",float) = 0.0
        _range("range",range(0,1)) =0.0
        _vector("vector",vector) = (1,1,1,1)
        _Color("color",color) = (0.5,0.5,0.5,0.5)*/
        _Maincolor("Maincolor",color)= (1,1,1,1)
        _MainTex("MainTex",2D)= "white"{}
        _Noise("_Noise",2D)= "white"{}
        _cutout("cutout",range(-0.1,1)) = 0.0
        _Speed("Speed",vector)=(1,1,0,0)
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
                float4 normal_world : TEXCOORD1;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORDO;
                float2 pos_uv : TEXCOORD1;
                float4 normal_world : TEXCOORD2;
            };

            float4 _Color,_Speed,_Maincolor;
            float _cutout;
            sampler2D _MainTex,_Noise;
            float4 _MainTex_ST,_Noise_ST;

            v2f vert(appdate v)
            {
                v2f o;
                /*float4 pos_world = mul(unity_ObjectToWorld, v.vertex);
                float4 pos_view = mul(UNITY_MATRIX_V, pos_world);*/
                float4 pos_clip = UnityObjectToClipPos(v.vertex);
                o.pos = pos_clip;
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                o.pos_uv = v.vertex.yz*_MainTex_ST.xy+ _MainTex_ST.zw;
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                float4 col = tex2D(_MainTex,  i.uv+_Time.y*_Speed.xy);
                float4 noise = tex2D(_Noise,  i.uv+_Time.y*_Speed.zw);
                
                clip(col.r-noise.r-_cutout);
                return _Maincolor;
            }
            ENDCG



        }
    }
}