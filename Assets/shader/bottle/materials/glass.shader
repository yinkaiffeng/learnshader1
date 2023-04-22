// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "glass"
{
	Properties
	{
		_RefractIntensity("RefractIntensity", Float) = 1.2
		_RefractTexture("RefractTexture", 2D) = "white" {}
		_RefractColor("RefractColor", Color) = (0,0.914711,1,0)
		_MatCapTexture("MatCapTexture", 2D) = "white" {}
		_min("min", Float) = 0
		_max("max", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform sampler2D _MatCapTexture;
		uniform float4 _RefractColor;
		uniform sampler2D _RefractTexture;
		uniform float _min;
		uniform float _max;
		uniform float _RefractIntensity;


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView6 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult7 = ASESafeNormalize( objToView6 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 break9 = cross( normalizeResult7 , mul( UNITY_MATRIX_V, float4( ase_normWorldNormal , 0.0 ) ).xyz );
			float2 appendResult10 = (float2(-break9.y , break9.x));
			float2 MatCapUV213 = (appendResult10*0.5 + 0.5);
			float4 tex2DNode33 = tex2D( _MatCapTexture, MatCapUV213 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult18 = dot( ase_normWorldNormal , ase_worldViewDir );
			float smoothstepResult19 = smoothstep( _min , _max , dotResult18);
			float Thickness21 = ( 1.0 - smoothstepResult19 );
			float temp_output_22_0 = ( Thickness21 * _RefractIntensity );
			float4 lerpResult30 = lerp( _RefractColor , tex2D( _RefractTexture, ( MatCapUV213 + temp_output_22_0 ) ) , saturate( temp_output_22_0 ));
			o.Emission = (( tex2DNode33 + lerpResult30 )).rgb;
			o.Alpha = saturate( max( tex2DNode33.r , Thickness21 ) );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
3840;0;1920;1019;3946.43;2276.139;4.503801;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-1285,-392;Inherit;False;1780.874;553.2682;MatCapUV2;12;12;10;11;9;2;8;7;5;6;4;3;13;;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;5;-1273,-305;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;6;-1089,-310;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-1207,-13;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;3;-1180,-144;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;14;-1259.129,270.3854;Inherit;False;1312.39;525.3414;Thickness;8;15;17;18;19;20;21;45;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-944,-51;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;7;-884,-235;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;15;-1191.926,370.3041;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;8;-693,-210;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-1195.926,580.3041;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;18;-873.926,482.3041;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-871.6685,582.0005;Inherit;False;Property;_min;min;5;0;Create;True;0;0;0;False;0;False;0;-0.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-880.6685,668.0005;Inherit;False;Property;_max;max;6;0;Create;True;0;0;0;False;0;False;0;0.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;-517,-229;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SmoothstepOpNode;19;-690.926,542.3041;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;11;-385,-68;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-260,-279;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;20;-382.926,534.3041;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;12;-39.92688,-219.9504;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-186.1552,547.1911;Inherit;True;Thickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1382.161,1452.817;Inherit;False;21;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1389.161,1563.817;Inherit;False;Property;_RefractIntensity;RefractIntensity;0;0;Create;True;0;0;0;False;0;False;1.2;1.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;240.0731,-238.9504;Inherit;False;MatCapUV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1193.161,1302.817;Inherit;False;13;MatCapUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1131.716,1484.229;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-874.1611,1393.817;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;29;-491.8848,1186.77;Inherit;False;Property;_RefractColor;RefractColor;3;0;Create;True;0;0;0;False;0;False;0,0.914711,1,0;0.254717,0.254717,0.254717,0.4941176;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;32;-554.326,911.8979;Inherit;False;13;MatCapUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-551.1611,1396.817;Inherit;True;Property;_RefractTexture;RefractTexture;2;0;Create;True;0;0;0;False;0;False;-1;None;94ce4514ce1a9e64b8e874e1d2929911;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;31;-516.7285,1688.116;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-293.9159,882.636;Inherit;True;Property;_MatCapTexture;MatCapTexture;4;0;Create;True;0;0;0;False;0;False;-1;None;dc93a6389b0d13e45984504bc748589d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;272.1745,1490.968;Inherit;True;21;Thickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;30;-75.95097,1244.196;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;325.9415,969.8966;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;37;523.5851,1309.68;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;38;869.5851,1290.68;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;43;605.5456,1091.787;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;44;1275.232,868.4821;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;5;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;7;0;6;0
WireConnection;8;0;7;0
WireConnection;8;1;4;0
WireConnection;18;0;15;0
WireConnection;18;1;17;0
WireConnection;9;0;8;0
WireConnection;19;0;18;0
WireConnection;19;1;45;0
WireConnection;19;2;46;0
WireConnection;11;0;9;1
WireConnection;10;0;11;0
WireConnection;10;1;9;0
WireConnection;20;0;19;0
WireConnection;12;0;10;0
WireConnection;21;0;20;0
WireConnection;13;0;12;0
WireConnection;22;0;23;0
WireConnection;22;1;24;0
WireConnection;25;0;26;0
WireConnection;25;1;22;0
WireConnection;28;1;25;0
WireConnection;31;0;22;0
WireConnection;33;1;32;0
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;30;2;31;0
WireConnection;34;0;33;0
WireConnection;34;1;30;0
WireConnection;37;0;33;1
WireConnection;37;1;36;0
WireConnection;38;0;37;0
WireConnection;43;0;34;0
WireConnection;44;2;43;0
WireConnection;44;9;38;0
ASEEND*/
//CHKSM=1E1C74501D013C58E224DC4A524AB239C6E16F26