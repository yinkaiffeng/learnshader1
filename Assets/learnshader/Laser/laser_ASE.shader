// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "laser_ASE"
{
	Properties
	{
		[Normal]_NormalTex("NormalTex", 2D) = "bump" {}
		_LaserRange("LaserRange", Range( 1 , 10)) = 2
		_LaserPos("LaserPos", Range( -1 , 1)) = 0
		_LaserOffset("LaserOffset", Range( -2 , 2)) = 1
		[Enum(A,0,B,1)]_Float2(" 颜色方案", Float) = 1
		_BumpScale("BumpScale", Range( -2 , 2)) = 1
		_CubeMapPow("CubeMapPow", Range( 0 , 1)) = 0.8
		_CubeMapRange("CubeMapRange", Range( 0 , 10)) = 1
		_CubeMapMipLevel("CubeMapMipLevel", Range( 0 , 7)) = 3
		_CubeMap("CubeMap", CUBE) = "white" {}
		_MainTex("MainTex", 2D) = "white" {}
		_MaskTex("MaskTex", 2D) = "white" {}
		_V("V", Range( -1 , 1)) = 0
		_S("S", Range( -1 , 1)) = 0
		_H("H", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _Float2;
		uniform samplerCUBE _CubeMap;
		uniform sampler2D _NormalTex;
		uniform float4 _NormalTex_ST;
		uniform float _BumpScale;
		uniform float _LaserPos;
		uniform float _LaserRange;
		uniform float _LaserOffset;
		uniform float _CubeMapMipLevel;
		uniform float _CubeMapPow;
		uniform float _CubeMapRange;
		uniform float _H;
		uniform float _S;
		uniform float _V;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform sampler2D _MaskTex;
		uniform float4 _MaskTex_ST;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float ColorType50 = _Float2;
			float2 uv_NormalTex = i.uv_texcoord * _NormalTex_ST.xy + _NormalTex_ST.zw;
			float3 NormalTex45 = UnpackScaleNormal( tex2D( _NormalTex, uv_NormalTex ), _BumpScale );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult8 = dot( normalize( (WorldNormalVector( i , NormalTex45 )) ) , ase_worldViewDir );
			float LaserPos43 = _LaserPos;
			float LaserRange42 = _LaserRange;
			float LaserOffset44 = _LaserOffset;
			float faceRatio55 = ( pow( ( 1.0 - abs( ( ( saturate( max( ( dotResult8 + LaserPos43 ) , 0.0 ) ) * 2.0 ) - 1.0 ) ) ) , LaserRange42 ) * LaserOffset44 );
			float3 reflectDir76 = reflect( -ase_worldViewDir , normalize( (WorldNormalVector( i , NormalTex45 )) ) );
			float3 break82 = reflectDir76;
			float CubeMapMipLevel49 = _CubeMapMipLevel;
			float4 appendResult87 = (float4(( faceRatio55 + break82.x ) , break82.y , break82.z , CubeMapMipLevel49));
			float4 appendResult89 = (float4(break82.x , break82.y , break82.z , CubeMapMipLevel49));
			float4 appendResult92 = (float4(break82.x , ( faceRatio55 + break82.y ) , break82.z , CubeMapMipLevel49));
			float3 appendResult107 = (float3(texCUBElod( _CubeMap, float4( appendResult87.xyz, CubeMapMipLevel49) ).r , texCUBElod( _CubeMap, float4( appendResult89.xyz, CubeMapMipLevel49) ).g , texCUBElod( _CubeMap, float4( appendResult92.xyz, CubeMapMipLevel49) ).b));
			float CubeMapPow47 = _CubeMapPow;
			float3 temp_cast_3 = (CubeMapPow47).xxx;
			float CubeMapRange48 = _CubeMapRange;
			float3 temp_cast_4 = (CubeMapRange48).xxx;
			float4 appendResult115 = (float4(pow( saturate( ( appendResult107 - temp_cast_3 ) ) , temp_cast_4 ) , 1.0));
			float4 Laser123 = appendResult115;
			float3 break138 = reflectDir76;
			float4 appendResult156 = (float4(break138.x , ( faceRatio55 + break138.y ) , break138.z , CubeMapMipLevel49));
			float4 appendResult158 = (float4(break138.x , break138.y , break138.z , CubeMapMipLevel49));
			float4 appendResult155 = (float4(( break138.z + faceRatio55 ) , break138.y , break138.z , CubeMapMipLevel49));
			float3 appendResult164 = (float3(texCUBElod( _CubeMap, float4( appendResult156.xyz, CubeMapMipLevel49) ).r , texCUBElod( _CubeMap, float4( appendResult158.xyz, CubeMapMipLevel49) ).g , texCUBElod( _CubeMap, float4( appendResult155.xyz, CubeMapMipLevel49) ).b));
			float3 temp_cast_8 = (CubeMapPow47).xxx;
			float3 temp_cast_9 = (CubeMapRange48).xxx;
			float4 appendResult170 = (float4(pow( saturate( ( appendResult164 - temp_cast_8 ) ) , temp_cast_9 ) , 1.0));
			float4 Laser02171 = appendResult170;
			float3 hsvTorgb129 = RGBToHSV( ( ColorType50 == 0.0 ? Laser123 : Laser02171 ).xyz );
			float3 hsvTorgb130 = HSVToRGB( float3(( hsvTorgb129.x + _H ),( hsvTorgb129.y + _S ),( hsvTorgb129.z + _V )) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 MainTex118 = tex2D( _MainTex, uv_MainTex );
			float2 uv_MaskTex = i.uv_texcoord * _MaskTex_ST.xy + _MaskTex_ST.zw;
			float4 MaskTex122 = tex2D( _MaskTex, uv_MaskTex );
			float4 lerpResult125 = lerp( float4( hsvTorgb130 , 0.0 ) , MainTex118 , (MaskTex122).a);
			o.Emission = lerpResult125.rgb;
			float temp_output_120_0 = (MainTex118).a;
			o.Alpha = temp_output_120_0;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;29;-1185.947,-2099.908;Inherit;False;901.3354;1713.837;Properties;23;45;33;50;118;117;48;40;47;39;46;77;49;44;41;32;42;30;43;31;4;37;121;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-1120.93,-1648.209;Inherit;False;Property;_BumpScale;BumpScale;5;0;Create;True;0;0;0;False;0;False;1;0.1;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-849.8649,-1692.621;Inherit;True;Property;_NormalTex;NormalTex;0;1;[Normal];Create;True;0;0;0;False;0;False;-1;None;270a0b0beb7a2f442852085fb9428431;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;56;-2482.717,-305.8235;Inherit;False;2608.411;635.0403;faceRatio;19;9;6;10;14;18;17;19;22;21;23;25;51;24;8;52;53;54;27;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-568.3171,-1687.432;Inherit;False;NormalTex;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1112.337,-1964.604;Inherit;False;Property;_LaserPos;LaserPos;2;0;Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2432.717,-241.7418;Inherit;False;45;NormalTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-774.0849,-1954.508;Inherit;False;LaserPos;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;9;-2121.637,-255.8235;Inherit;True;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;6;-2103.637,-8.823424;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;52;-1822.305,27.2168;Inherit;False;43;LaserPos;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;8;-1854.88,-249.0416;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1611.713,-61.50232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;14;-1472.946,-92.72133;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1238.143,121.4573;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;-1233.342,-79.04262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1099.143,206.4573;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1092.943,31.55728;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-914.7428,83.95729;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-2516.234,343.9392;Inherit;True;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;59;-2508.6,625.4868;Inherit;False;45;NormalTex;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1114.912,-2034.575;Inherit;False;Property;_LaserRange;LaserRange;1;0;Create;True;0;0;0;False;0;False;2;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;62;-2274.712,330.7335;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-770.0849,-2038.508;Inherit;False;LaserRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1113.337,-1883.604;Inherit;False;Property;_LaserOffset;LaserOffset;3;0;Create;True;0;0;0;False;0;False;1;2;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;61;-2295.987,622.1904;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;23;-781.6079,-7.917815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1117.084,-1098.508;Inherit;False;Property;_CubeMapMipLevel;CubeMapMipLevel;8;0;Create;True;0;0;0;False;0;False;3;2.76;0;7;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-776.0849,-1880.508;Inherit;False;LaserOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-664.4097,-20.17471;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;57;-1919.131,498.6196;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;53;-692.3055,119.2168;Inherit;False;42;LaserRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;66;-2607.514,963.1489;Inherit;False;2354.287;932.8776;type1;36;123;115;112;116;113;111;108;107;109;91;88;78;90;89;94;87;92;71;98;99;83;100;104;101;93;103;97;84;102;96;95;106;105;82;85;80;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;24;-510.4097,22.82532;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-788.0849,-1096.508;Inherit;False;CubeMapMipLevel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-1636.231,498.7534;Inherit;False;reflectDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;54;-525.3055,213.2168;Inherit;False;44;LaserOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-262.4097,111.8253;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;77;-1113.601,-1525.945;Inherit;True;Property;_CubeMap;CubeMap;9;0;Create;True;0;0;0;False;0;False;None;8723116a3c4d1644aad68cc228270bd4;False;white;LockedToCube;Cube;-1;0;2;SAMPLERCUBE;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-98.30553,119.2168;Inherit;False;faceRatio;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-861.0849,-1498.508;Inherit;False;CubeMap;-1;True;1;0;SAMPLERCUBE;0,0,0,0;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-1118.084,-1287.508;Inherit;False;Property;_CubeMapPow;CubeMapPow;6;0;Create;True;0;0;0;False;0;False;0.8;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-772.0849,-1283.508;Inherit;False;CubeMapPow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1117.084,-1211.508;Inherit;False;Property;_CubeMapRange;CubeMapRange;7;0;Create;True;0;0;0;False;0;False;1;0.88;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-773.0849,-1194.508;Inherit;False;CubeMapRange;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-1092.678,-783.222;Inherit;True;Property;_MaskTex;MaskTex;11;0;Create;True;0;0;0;False;0;False;-1;None;edd2a85edd164f64d9f096c4b29350c3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;117;-1120.88,-1011.751;Inherit;True;Property;_MainTex;MainTex;10;0;Create;True;0;0;0;False;0;False;-1;None;cedc8d00d7177214aaf60f806dced22e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-761.236,-754.4748;Inherit;False;MaskTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-789.4379,-983.0038;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;50;-790.0849,-1789.508;Inherit;False;ColorType;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-2514.327,1225.043;Inherit;False;76;reflectDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-2416.789,1597.933;Inherit;False;49;CubeMapMipLevel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;82;-2303.127,1218.543;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;105;-2193.24,1618.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;106;-2221.24,1614.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;95;-1936.319,1296.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;96;-1951.319,1334.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;102;-2218.24,1485.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;84;-2322.027,1127.643;Inherit;False;55;faceRatio;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;97;-1960.319,1364.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;103;-2188.24,1428.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-2059.716,1556.002;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;101;-1952.24,1482.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;104;-1943.24,1270.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;100;-1949.319,1445.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-2126.027,1155.643;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;99;-1934.319,1421.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;98;-1922.319,1393.665;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-2356.317,1019.377;Inherit;False;46;CubeMap;1;0;OBJECT;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-1890.916,1602.501;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;87;-1899.023,1160.344;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;94;-1749.116,1211.401;Inherit;False;1;0;SAMPLERCUBE;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.DynamicAppendNode;89;-1893.642,1376.129;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;90;-1732.458,1144.151;Inherit;False;1;0;SAMPLERCUBE;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.SamplerNode;78;-1631.626,1029.643;Inherit;True;Property;_TextureSample0;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;88;-1632.342,1325.43;Inherit;True;Property;_TextureSample1;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;91;-1636.916,1579.701;Inherit;True;Property;_TextureSample2;Texture Sample 2;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;109;-1253.48,1395.127;Inherit;False;47;CubeMapPow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-1255.107,1154.371;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;108;-1040.379,1261.735;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;111;-864.6934,1269.869;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-1007.896,1486.479;Inherit;False;48;CubeMapRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-704.9962,1534.579;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;112;-702.7224,1368.447;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;115;-556.6973,1391.836;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;120;-371.6298,4453.112;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;128;-819.6299,4341.112;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-1075.63,4389.112;Inherit;False;122;MaskTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-835.6299,4229.112;Inherit;False;118;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;125;-243.6299,4053.112;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;129;-931.6299,3653.112;Inherit;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;131;-947.6299,4021.112;Inherit;False;Property;_V;V;12;0;Create;True;0;0;0;False;0;False;0;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;134;-630.9983,3555.815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;135;-2618.264,2032.577;Inherit;False;2354.287;932.8776;type1;36;171;170;169;168;167;166;165;164;163;162;161;160;159;158;157;156;155;154;153;152;151;150;149;148;147;146;145;144;143;142;141;140;139;138;137;136;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-2525.077,2294.471;Inherit;False;76;reflectDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;137;-2427.539,2667.361;Inherit;False;49;CubeMapMipLevel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;138;-2313.877,2287.971;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;139;-2203.99,2687.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;140;-2231.99,2683.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;141;-1947.07,2366.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;142;-1962.07,2404.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;143;-2228.99,2554.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-2332.777,2197.071;Inherit;False;55;faceRatio;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;145;-1971.07,2434.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;146;-2198.99,2497.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;148;-1962.991,2551.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;149;-1953.991,2339.452;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;150;-1960.07,2515.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;152;-1945.07,2491.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;153;-1933.07,2463.093;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-2367.067,2088.805;Inherit;False;46;CubeMap;1;0;OBJECT;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.DynamicAppendNode;156;-1909.774,2229.772;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;157;-1759.867,2280.829;Inherit;False;1;0;SAMPLERCUBE;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.DynamicAppendNode;158;-1904.393,2445.557;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;159;-1743.209,2213.579;Inherit;False;1;0;SAMPLERCUBE;;False;1;SAMPLERCUBE;0
Node;AmplifyShaderEditor.SamplerNode;160;-1642.377,2099.071;Inherit;True;Property;_TextureSample3;Texture Sample 0;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;161;-1643.093,2394.858;Inherit;True;Property;_TextureSample4;Texture Sample 1;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;162;-1647.667,2649.129;Inherit;True;Property;_TextureSample5;Texture Sample 2;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;163;-1264.231,2464.555;Inherit;False;47;CubeMapPow;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;164;-1265.858,2223.799;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;165;-1051.13,2331.163;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;166;-875.4437,2339.297;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;167;-1018.646,2555.907;Inherit;False;48;CubeMapRange;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-715.7465,2604.007;Inherit;False;Constant;_Float4;Float 3;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;169;-713.4727,2437.875;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;170;-567.4477,2461.264;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;155;-1893.667,2670.929;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;123;-463.9612,1246.961;Inherit;False;Laser;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;-485.1119,2312.489;Inherit;False;Laser02;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Compare;65;-1189.568,3374.173;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-1346.63,3727.112;Inherit;True;123;Laser;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;174;-1486.796,3551.729;Inherit;False;171;Laser02;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-1491.796,3449.729;Inherit;False;123;Laser;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;172;-1498.121,3330.012;Inherit;False;50;ColorType;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1063.337,-1788.604;Inherit;False;Property;_Float2; 颜色方案;4;1;[Enum];Create;False;0;2;A;0;B;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;151;-2104.777,2183.071;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-2058.466,2570.43;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-946.6299,3935.112;Inherit;False;Property;_S;S;13;0;Create;True;0;0;0;False;0;False;0;0.16;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-939.6377,3873.912;Inherit;False;Property;_H;H;14;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;130;-297.6299,3715.112;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-600.6299,3832.112;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;176;-578.6377,3729.912;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;199.3703,4054.112;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;laser_ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;5;37;0
WireConnection;45;0;4;0
WireConnection;43;0;31;0
WireConnection;9;0;51;0
WireConnection;8;0;9;0
WireConnection;8;1;6;0
WireConnection;10;0;8;0
WireConnection;10;1;52;0
WireConnection;14;0;10;0
WireConnection;17;0;14;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;21;0;18;0
WireConnection;21;1;22;0
WireConnection;62;0;58;0
WireConnection;42;0;30;0
WireConnection;61;0;59;0
WireConnection;23;0;21;0
WireConnection;44;0;32;0
WireConnection;25;0;23;0
WireConnection;57;0;62;0
WireConnection;57;1;61;0
WireConnection;24;0;25;0
WireConnection;24;1;53;0
WireConnection;49;0;41;0
WireConnection;76;0;57;0
WireConnection;27;0;24;0
WireConnection;27;1;54;0
WireConnection;55;0;27;0
WireConnection;46;0;77;0
WireConnection;47;0;39;0
WireConnection;48;0;40;0
WireConnection;122;0;121;0
WireConnection;118;0;117;0
WireConnection;50;0;33;0
WireConnection;82;0;80;0
WireConnection;105;0;85;0
WireConnection;106;0;85;0
WireConnection;95;0;82;0
WireConnection;96;0;82;1
WireConnection;102;0;106;0
WireConnection;97;0;82;2
WireConnection;103;0;105;0
WireConnection;93;0;84;0
WireConnection;93;1;82;1
WireConnection;101;0;102;0
WireConnection;104;0;103;0
WireConnection;100;0;97;0
WireConnection;83;0;84;0
WireConnection;83;1;82;0
WireConnection;99;0;96;0
WireConnection;98;0;95;0
WireConnection;92;0;82;0
WireConnection;92;1;93;0
WireConnection;92;2;82;2
WireConnection;92;3;85;0
WireConnection;87;0;83;0
WireConnection;87;1;82;1
WireConnection;87;2;82;2
WireConnection;87;3;104;0
WireConnection;94;0;71;0
WireConnection;89;0;98;0
WireConnection;89;1;99;0
WireConnection;89;2;100;0
WireConnection;89;3;101;0
WireConnection;90;0;71;0
WireConnection;78;0;71;0
WireConnection;78;1;87;0
WireConnection;78;2;85;0
WireConnection;88;0;90;0
WireConnection;88;1;89;0
WireConnection;88;2;85;0
WireConnection;91;0;94;0
WireConnection;91;1;92;0
WireConnection;91;2;85;0
WireConnection;107;0;78;1
WireConnection;107;1;88;2
WireConnection;107;2;91;3
WireConnection;108;0;107;0
WireConnection;108;1;109;0
WireConnection;111;0;108;0
WireConnection;112;0;111;0
WireConnection;112;1;113;0
WireConnection;115;0;112;0
WireConnection;115;3;116;0
WireConnection;120;0;119;0
WireConnection;128;0;127;0
WireConnection;125;0;130;0
WireConnection;125;1;119;0
WireConnection;125;2;128;0
WireConnection;129;0;65;0
WireConnection;134;0;129;2
WireConnection;134;1;133;0
WireConnection;138;0;136;0
WireConnection;139;0;137;0
WireConnection;140;0;137;0
WireConnection;141;0;138;0
WireConnection;142;0;138;1
WireConnection;143;0;140;0
WireConnection;145;0;138;2
WireConnection;146;0;139;0
WireConnection;148;0;143;0
WireConnection;149;0;146;0
WireConnection;150;0;145;0
WireConnection;152;0;142;0
WireConnection;153;0;141;0
WireConnection;156;0;138;0
WireConnection;156;1;151;0
WireConnection;156;2;138;2
WireConnection;156;3;149;0
WireConnection;157;0;154;0
WireConnection;158;0;153;0
WireConnection;158;1;152;0
WireConnection;158;2;150;0
WireConnection;158;3;148;0
WireConnection;159;0;154;0
WireConnection;160;0;154;0
WireConnection;160;1;156;0
WireConnection;160;2;137;0
WireConnection;161;0;159;0
WireConnection;161;1;158;0
WireConnection;161;2;137;0
WireConnection;162;0;157;0
WireConnection;162;1;155;0
WireConnection;162;2;137;0
WireConnection;164;0;160;1
WireConnection;164;1;161;2
WireConnection;164;2;162;3
WireConnection;165;0;164;0
WireConnection;165;1;163;0
WireConnection;166;0;165;0
WireConnection;169;0;166;0
WireConnection;169;1;167;0
WireConnection;170;0;169;0
WireConnection;170;3;168;0
WireConnection;155;0;147;0
WireConnection;155;1;138;1
WireConnection;155;2;138;2
WireConnection;155;3;137;0
WireConnection;123;0;115;0
WireConnection;171;0;170;0
WireConnection;65;0;172;0
WireConnection;65;2;173;0
WireConnection;65;3;174;0
WireConnection;151;0;144;0
WireConnection;151;1;138;1
WireConnection;147;0;138;2
WireConnection;147;1;144;0
WireConnection;130;0;176;0
WireConnection;130;1;134;0
WireConnection;130;2;132;0
WireConnection;132;0;129;3
WireConnection;132;1;131;0
WireConnection;176;0;129;1
WireConnection;176;1;175;0
WireConnection;1;2;125;0
WireConnection;1;9;120;0
WireConnection;1;10;120;0
ASEEND*/
//CHKSM=02F3DFBE0DE8BA57A7F12E12212CAEC5D4C04CB0