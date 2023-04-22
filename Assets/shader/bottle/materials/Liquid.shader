// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader ""
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_WobbleX("液面摆动X", Float) = 0
		_WobbleZ("液面摆动Z", Float) = 0
		_liquidlevel("液面高度", Range( 0 , 1)) = 0
		_Heightremapping("高度重映射", Vector) = (0,1,2.2,-1.3)
		_density("液面密度", Float) = 0
		_Waveamplitude("波浪振幅", Float) = 0.5
		_Liquidlevelvelocity("液面速度", Float) = 1
		_Maintexture("主纹理", 2D) = "white" {}
		_texturevelocityX("主纹理速度X", Float) = 0
		_texturevelocityY("主纹理速度Y", Float) = 0
		_texturebrightness("主纹理亮度", Float) = 0
		_ParallaxtextureA("视差纹理A", 2D) = "white" {}
		_AXYdensityZWvelocity("A_XY密度_ZW速度", Vector) = (0,0,0,0)
		_Abrightness("A亮度", Float) = 1
		_ParallaxtextureB("视差纹理B", 2D) = "white" {}
		_BXYdensityZWvelocity("B_XY密度_ZW速度", Vector) = (0,0,0,0)
		_Bbrightness("B亮度", Float) = 1
		_Parallaxindex("视差折射率", Range( 0.1 , 3)) = 0.1
		_EdgeLightSetXbasecolorYbrightnessZwidth("边缘光设置X底色Y亮度Z宽度", Vector) = (0,1,5,0)
		_Edgelightcolor("边缘光颜色", Color) = (1,1,1,0)
		_Liquidcolor("液面颜色", Color) = (0,0,0,0)
		[HideInInspector]_ParallaxtextureB1("视差纹理B", 2D) = "white" {}
		_XYdensityZWvelocity("液面纹理XY密度ZW速度", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
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
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
			half ASEVFace : VFACE;
		};

		uniform sampler2D _ParallaxtextureA;
		uniform float4 _AXYdensityZWvelocity;
		uniform float _Parallaxindex;
		uniform float _Abrightness;
		uniform sampler2D _ParallaxtextureB;
		uniform float4 _BXYdensityZWvelocity;
		uniform float _Bbrightness;
		uniform float3 _EdgeLightSetXbasecolorYbrightnessZwidth;
		uniform float4 _Edgelightcolor;
		uniform sampler2D _Maintexture;
		uniform float _texturevelocityX;
		uniform float _texturevelocityY;
		uniform float _texturebrightness;
		uniform float _liquidlevel;
		uniform float4 _Heightremapping;
		uniform float _WobbleX;
		uniform float _WobbleZ;
		uniform float _density;
		uniform float _Liquidlevelvelocity;
		uniform float _Waveamplitude;
		uniform sampler2D _ParallaxtextureB1;
		uniform float4 _XYdensityZWvelocity;
		uniform float4 _Liquidcolor;
		uniform float _Cutoff = 0.5;


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 appendResult101 = (float2(_AXYdensityZWvelocity.z , _AXYdensityZWvelocity.w));
			float2 appendResult102 = (float2(_AXYdensityZWvelocity.x , _AXYdensityZWvelocity.y));
			float2 panner104 = ( 1.0 * _Time.y * appendResult101 + ( i.uv_texcoord * appendResult102 ));
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult84 = normalize( ase_worldViewDir );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentPos85 = mul( ase_worldToTangent, ase_worldNormal);
			float3 normalizeResult86 = ASESafeNormalize( worldToTangentPos85 );
			float3 break90 = refract( normalizeResult84 , normalizeResult86 , ( 1.0 / _Parallaxindex ) );
			float2 appendResult91 = (float2(break90.x , break90.y));
			float2 parallax93 = ( appendResult91 / break90.z );
			float2 appendResult100 = (float2(_BXYdensityZWvelocity.z , _BXYdensityZWvelocity.w));
			float2 appendResult99 = (float2(_BXYdensityZWvelocity.x , _BXYdensityZWvelocity.y));
			float2 panner106 = ( 1.0 * _Time.y * appendResult100 + ( i.uv_texcoord * appendResult99 ));
			float4 AB118 = ( ( tex2D( _ParallaxtextureA, ( panner104 + parallax93 ) ) * _Abrightness ) + ( tex2D( _ParallaxtextureB, ( panner106 + parallax93 ) ) * _Bbrightness ) );
			float fresnelNdotV11 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode11 = ( _EdgeLightSetXbasecolorYbrightnessZwidth.x + _EdgeLightSetXbasecolorYbrightnessZwidth.y * pow( 1.0 - fresnelNdotV11, _EdgeLightSetXbasecolorYbrightnessZwidth.z ) );
			float2 appendResult4 = (float2(_texturevelocityX , _texturevelocityY));
			float2 panner5 = ( 1.0 * _Time.y * appendResult4 + i.uv_texcoord);
			float4 tex2DNode6 = tex2D( _Maintexture, panner5 );
			float4 transform37 = mul(unity_ObjectToWorld,float4(0,0,0,1));
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 rotatedValue43 = RotateAroundAxis( float3( 0,0,0 ), ase_vertex3Pos, normalize( float3(-1,0,0) ), 90.0 );
			float3 break49 = ( ( ase_worldPos - (transform37).xyz ) + ( _WobbleX * ase_vertex3Pos ) + ( rotatedValue43 * _WobbleZ ) );
			float3 ase_objectScale = float3( length( unity_ObjectToWorld[ 0 ].xyz ), length( unity_ObjectToWorld[ 1 ].xyz ), length( unity_ObjectToWorld[ 2 ].xyz ) );
			float3 temp_output_50_0 = ( 1.0 / ase_objectScale );
			float2 appendResult53 = (float2(break49.x , break49.z));
			float3 temp_cast_1 = (0.5).xxx;
			float3 break72 = ( ( sin( ( ( float3( appendResult53 ,  0.0 ) * temp_output_50_0 * _density ) + ( _Time.y * _Liquidlevelvelocity ) ) ) - temp_cast_1 ) * _Waveamplitude );
			float clip77 = step( ( ( (_Heightremapping.z + (_liquidlevel - _Heightremapping.x) * (_Heightremapping.w - _Heightremapping.z) / (_Heightremapping.y - _Heightremapping.x)) + ( break49.y * (temp_output_50_0).y ) ) + ( break72.x * break72.y ) ) , 0.5 );
			float2 appendResult27 = (float2(_XYdensityZWvelocity.z , _XYdensityZWvelocity.w));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 appendResult26 = (float2(_XYdensityZWvelocity.x , _XYdensityZWvelocity.y));
			float2 panner28 = ( 1.0 * _Time.y * appendResult27 + ( (ase_screenPosNorm).xy * appendResult26 ));
			float4 BACK33 = ( tex2D( _ParallaxtextureB1, panner28 ) + _Liquidcolor );
			float4 switchResult18 = (((i.ASEVFace>0)?(( AB118 + ( ( fresnelNode11 * _Edgelightcolor ) + ( ( tex2DNode6 * _texturebrightness * tex2DNode6.a ) * clip77 ) ) )):(BACK33)));
			o.Emission = switchResult18.rgb;
			float temp_output_78_0 = clip77;
			o.Alpha = temp_output_78_0;
			clip( temp_output_78_0 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				float4 screenPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				o.screenPos = ComputeScreenPos( o.pos );
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
				surfIN.screenPos = IN.screenPos;
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
Version=18935
3840;0;1920;1019;6232.753;1170.2;2.343198;True;False
Node;AmplifyShaderEditor.CommentaryNode;34;-5317.828,1043.908;Inherit;False;4275.937;1480.451;液体裁剪面;40;36;37;38;35;39;40;41;42;43;44;45;46;47;49;50;51;52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;70;71;72;73;75;76;77;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;36;-5185.605,1487.974;Inherit;False;Constant;_Vector1;Vector 1;2;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;37;-4961.948,1519.921;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;40;-4995.947,1709.921;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-4967.276,2036.6;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;90;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;41;-4970.438,1871.886;Inherit;False;Constant;_Vector2;Vector 2;2;0;Create;True;0;0;0;False;0;False;-1,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;45;-4486.576,2038.6;Inherit;False;Property;_WobbleZ;液面摆动Z;2;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;43;-4673.276,1846.6;Inherit;False;True;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-4611.276,1624.6;Inherit;False;Property;_WobbleX;液面摆动X;1;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;38;-4743.948,1482.921;Inherit;False;True;True;True;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;35;-4863.064,1293.302;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;39;-4505.948,1378.921;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-4292.276,1683.6;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-4286.276,1911.6;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;79;-5212.867,-1717.691;Inherit;False;1883.252;748.1499;视差UV计算/parallax;13;87;83;86;84;85;82;81;88;89;90;91;92;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-3948.276,1544.6;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3992.276,1753.6;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;49;-3729.276,1545.6;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ObjectScaleNode;52;-3992.276,1911.6;Inherit;False;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;82;-5169.044,-1439.317;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;50;-3767.276,1792.6;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-5084.655,-1168.404;Inherit;False;Property;_Parallaxindex;视差折射率;18;0;Create;False;0;0;0;False;0;False;0.1;0.955;0.1;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;57;-3576.276,2135.6;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-3513.276,1773.6;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3524.276,2243.6;Inherit;False;Property;_Liquidlevelvelocity;液面速度;7;0;Create;False;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;85;-4893.044,-1440.317;Inherit;False;World;Tangent;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;87;-4896.044,-1275.317;Inherit;False;Constant;_Float4;Float 4;15;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;81;-5163.044,-1630.317;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;55;-3531.276,2000.6;Inherit;False;Property;_density;液面密度;5;0;Create;False;0;0;0;False;0;False;0;120;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-3285.276,2074.6;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;86;-4608.044,-1442.317;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;89;-4597.655,-1249.404;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-3294.276,1880.6;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;84;-4860.044,-1600.317;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-3092.276,1937.6;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RefractOpVec;83;-4357.044,-1505.317;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;94;-5347.703,-884.9205;Inherit;False;2764.694;949.5763;液体正面双视差 AB加颜色;23;95;96;97;99;100;101;102;103;104;105;106;108;109;110;111;112;114;115;116;118;117;113;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2889.276,2090.6;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;90;-4086.656,-1612.404;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SinOpNode;60;-2897.276,1945.6;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-3889.656,-1539.404;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-2651.276,2167.6;Inherit;False;Property;_Waveamplitude;波浪振幅;6;0;Create;False;0;0;0;False;0;False;0.5;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;96;-5278.576,-558.6313;Inherit;False;Property;_AXYdensityZWvelocity;A_XY密度_ZW速度;13;0;Create;False;0;0;0;False;0;False;0,0,0,0;2.15,1.22,0.1,-0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-2725.276,2005.6;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;97;-5275.276,-232.6313;Inherit;False;Property;_BXYdensityZWvelocity;B_XY密度_ZW速度;16;0;Create;False;0;0;0;False;0;False;0,0,0,0;2.22,1.05,0.1,0.03;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-3454.243,1203.812;Inherit;False;Property;_liquidlevel;液面高度;3;0;Create;False;0;0;0;False;0;False;0;0.471;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-2449.276,1873.6;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;71;-3575.243,1326.812;Inherit;False;Property;_Heightremapping;高度重映射;4;0;Create;False;0;0;0;False;0;False;0,1,2.2,-1.3;0,1,0.59,0.4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;92;-3691.656,-1475.404;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;65;-3514.243,1676.812;Inherit;False;False;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;102;-4989.576,-550.1313;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;95;-5283.576,-786.6313;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;99;-4959.576,-192.6313;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-3539.685,-1464.061;Inherit;False;parallax;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-3288.243,1570.812;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;20;-5196.1,174.9612;Inherit;False;1820.243;719.7471;背面/水面/基于屏幕空间的纹理;12;22;21;24;25;26;27;28;29;30;32;33;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;72;-2216.905,1826.092;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TFHCRemapNode;70;-3110.243,1259.812;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-4783.576,-756.6313;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;100;-4955.576,-89.63135;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;101;-4968.576,-447.1314;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4765.575,-312.5314;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;24;-5133.249,583.4021;Inherit;False;Property;_XYdensityZWvelocity;液面纹理XY密度ZW速度;23;0;Create;False;0;0;0;False;0;False;0,0,0,0;5,5,0.1,-0.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-2016.905,1801.092;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1996.882,675.5471;Inherit;False;Property;_texturevelocityY;主纹理速度Y;10;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-2790.243,1399.812;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;21;-5115.249,259.4021;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;109;-4490.665,-535.7958;Inherit;False;93;parallax;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;104;-4544.576,-687.6313;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;106;-4500.575,-350.1314;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-4502.064,-203.2956;Inherit;False;93;parallax;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1997.882,541.5472;Inherit;False;Property;_texturevelocityX;主纹理速度X;9;0;Create;False;0;0;0;False;0;False;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-4781.249,484.4021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;-4884.249,252.402;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1782.882,582.5471;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2012.882,395.5472;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-1805.905,1625.092;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1747.087,1755.967;Inherit;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-4143.265,-693.0955;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;108;-4138.064,-358.9956;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-3651.581,-237.2258;Inherit;False;Property;_Bbrightness;B亮度;17;0;Create;False;0;0;0;False;0;False;1;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;112;-3938.981,-432.2258;Inherit;True;Property;_ParallaxtextureB;视差纹理B;15;0;Create;False;0;0;0;False;0;False;-1;None;5fcf6fb5407bd7f429dbc51eb11b6ea1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;5;-1562.882,455.5472;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-4770.249,635.4021;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-3662.581,-535.2258;Inherit;False;Property;_Abrightness;A亮度;14;0;Create;False;0;0;0;False;0;False;1;-0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;75;-1565.391,1652.426;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-4547.249,352.4021;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;111;-3931.581,-719.2258;Inherit;True;Property;_ParallaxtextureA;视差纹理A;12;0;Create;False;0;0;0;False;0;False;-1;None;d62500b55ace5d747bd7efb661ce0b22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-3396.581,-411.2258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-3473.581,-709.2258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;10;-1402.359,-111.2027;Inherit;False;Property;_EdgeLightSetXbasecolorYbrightnessZwidth;边缘光设置X底色Y亮度Z宽度;19;0;Create;False;0;0;0;False;0;False;0,1,5;-0.26,2.7,1.67;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;6;-1364.882,325.5472;Inherit;True;Property;_Maintexture;主纹理;8;0;Create;False;0;0;0;False;0;False;-1;None;d62500b55ace5d747bd7efb661ce0b22;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;28;-4372.249,470.4021;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1274.882,585.5471;Inherit;False;Property;_texturebrightness;主纹理亮度;11;0;Create;False;0;0;0;False;0;False;0;1.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1350.087,1624.967;Inherit;True;clip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-3073.581,-551.2258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;13;-1032.386,125.0498;Inherit;False;Property;_Edgelightcolor;边缘光颜色;20;0;Create;False;0;0;0;False;0;False;1,1,1,0;0.01134745,0.04285501,0.1415094,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-996.8825,469.5472;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;-4142.249,667.4021;Inherit;False;Property;_Liquidcolor;液面颜色;21;0;Create;False;0;0;0;False;0;False;0,0,0,0;0.2823514,0.3041101,0.4245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;-4155.248,234.4021;Inherit;True;Property;_ParallaxtextureB1;视差纹理B;22;1;[HideInInspector];Create;False;0;0;0;False;0;False;112;None;5fcf6fb5407bd7f429dbc51eb11b6ea1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1001.08,648.037;Inherit;False;77;clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;11;-1043.386,-77.95021;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2834.581,-555.2258;Inherit;False;AB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-3751.25,556.4021;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-749.6934,501.9002;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-714.3862,15.04979;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;33;-3591.25,552.4021;Inherit;False;BACK;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-373.9917,233.3271;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-380.08,63.03696;Inherit;False;118;AB;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-115.08,392.037;Inherit;False;33;BACK;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-129.08,159.037;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;135.0788,461.3222;Inherit;False;77;clip;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwitchByFaceNode;18;155.92,256.037;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;122;-4141.733,423.1707;Inherit;True;Property;_TextureSample0;Texture Sample 0;24;1;[HideInInspector];Create;True;0;0;0;False;0;False;112;None;None;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;121;603.405,216.2691;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;0;36;0
WireConnection;43;0;41;0
WireConnection;43;1;42;0
WireConnection;43;3;40;0
WireConnection;38;0;37;0
WireConnection;39;0;35;0
WireConnection;39;1;38;0
WireConnection;46;0;47;0
WireConnection;46;1;40;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;48;0;39;0
WireConnection;48;1;46;0
WireConnection;48;2;44;0
WireConnection;49;0;48;0
WireConnection;50;0;51;0
WireConnection;50;1;52;0
WireConnection;53;0;49;0
WireConnection;53;1;49;2
WireConnection;85;0;82;0
WireConnection;56;0;57;0
WireConnection;56;1;58;0
WireConnection;86;0;85;0
WireConnection;89;0;87;0
WireConnection;89;1;88;0
WireConnection;54;0;53;0
WireConnection;54;1;50;0
WireConnection;54;2;55;0
WireConnection;84;0;81;0
WireConnection;59;0;54;0
WireConnection;59;1;56;0
WireConnection;83;0;84;0
WireConnection;83;1;86;0
WireConnection;83;2;89;0
WireConnection;90;0;83;0
WireConnection;60;0;59;0
WireConnection;91;0;90;0
WireConnection;91;1;90;1
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;63;0;61;0
WireConnection;63;1;64;0
WireConnection;92;0;91;0
WireConnection;92;1;90;2
WireConnection;65;0;50;0
WireConnection;102;0;96;1
WireConnection;102;1;96;2
WireConnection;99;0;97;1
WireConnection;99;1;97;2
WireConnection;93;0;92;0
WireConnection;66;0;49;1
WireConnection;66;1;65;0
WireConnection;72;0;63;0
WireConnection;70;0;68;0
WireConnection;70;1;71;1
WireConnection;70;2;71;2
WireConnection;70;3;71;3
WireConnection;70;4;71;4
WireConnection;103;0;95;0
WireConnection;103;1;102;0
WireConnection;100;0;97;3
WireConnection;100;1;97;4
WireConnection;101;0;96;3
WireConnection;101;1;96;4
WireConnection;105;0;95;0
WireConnection;105;1;99;0
WireConnection;73;0;72;0
WireConnection;73;1;72;1
WireConnection;67;0;70;0
WireConnection;67;1;66;0
WireConnection;104;0;103;0
WireConnection;104;2;101;0
WireConnection;106;0;105;0
WireConnection;106;2;100;0
WireConnection;26;0;24;1
WireConnection;26;1;24;2
WireConnection;22;0;21;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;74;0;67;0
WireConnection;74;1;73;0
WireConnection;107;0;104;0
WireConnection;107;1;109;0
WireConnection;108;0;106;0
WireConnection;108;1;110;0
WireConnection;112;1;108;0
WireConnection;5;0;1;0
WireConnection;5;2;4;0
WireConnection;27;0;24;3
WireConnection;27;1;24;4
WireConnection;75;0;74;0
WireConnection;75;1;76;0
WireConnection;25;0;22;0
WireConnection;25;1;26;0
WireConnection;111;1;107;0
WireConnection;114;0;112;0
WireConnection;114;1;116;0
WireConnection;113;0;111;0
WireConnection;113;1;115;0
WireConnection;6;1;5;0
WireConnection;28;0;25;0
WireConnection;28;2;27;0
WireConnection;77;0;75;0
WireConnection;117;0;113;0
WireConnection;117;1;114;0
WireConnection;7;0;6;0
WireConnection;7;1;8;0
WireConnection;7;2;6;4
WireConnection;29;1;28;0
WireConnection;11;1;10;1
WireConnection;11;2;10;2
WireConnection;11;3;10;3
WireConnection;118;0;117;0
WireConnection;30;0;29;0
WireConnection;30;1;32;0
WireConnection;9;0;7;0
WireConnection;9;1;15;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;33;0;30;0
WireConnection;14;0;12;0
WireConnection;14;1;9;0
WireConnection;16;0;17;0
WireConnection;16;1;14;0
WireConnection;18;0;16;0
WireConnection;18;1;19;0
WireConnection;122;1;28;0
WireConnection;121;2;18;0
WireConnection;121;9;78;0
WireConnection;121;10;78;0
ASEEND*/
//CHKSM=EA3BC5A687050353975822A8F5B934B362CDD813