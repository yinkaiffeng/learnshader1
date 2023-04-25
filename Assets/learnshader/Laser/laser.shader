Shader "Phone/laser"{
	Properties{
		_LaserRange("镭射范围",Range(1,10)) = 2
		_LaserPos("镭射位置",Range(-1,1)) = 0
		_LaserOffset("颜色偏移",Range(-2,2)) = 1

		[KeywordEnum(Plan_A,Plan_B)]_Type("颜色方案",Float) = 0
		[NoScaleOffset]
		_BumpMap("法线贴图",2D) = "bump"{}
		_BumpScale("法线贴图强度",Range(-2.0,2.0)) = 1
			[NoScaleOffset]
		_CubeMap("反射球贴图",cube) = "Skybox"{}
		_CubeMapPow("反射亮度",range(0,1)) = 0.8
		_CubeMapRange("亮度范围",range(1,10)) = 1
		_CubeMapMipLevel("反射模糊",range(0,7)) = 3



	}
		subshader{
			Tags{"RenderType" = "Opaque"}
			pass {
				Tags{"LightMode" = "ForWardBase"}

				CGPROGRAM

				#pragma vertex vert 
				#pragma fragment  frag 

				#include"UnityCG.cginc"


					//输入结构
					struct appdata
					{
						float4 vertex : POSITION;
						float2 uv : TEXCOORD0;
						//获取表面法线
						float3 normal:NORMAL;
						//获取表面切线
						float4 tangent:TANGENT;
					};

					struct v2f
					{
						float2 uv : TEXCOORD0;
						float4 vertex : SV_POSITION;

						//切线空间转世界空间数据3代4
						float4 T2W0:TEXCOORD1;
						float4 T2W1:TEXCOORD2;
						float4 T2W2:TEXCOORD3;
					};

					//定义法线贴图变量
					sampler2D _BumpMap;
					//定义法线强度变量
					float _BumpScale;
					//输入变量
					samplerCUBE _CubeMap;
					float _CubeMapMipLevel;
					float _LaserRange;
					float _LaserOffset;
					float _CubeMapPow;
					float _CubeMapRange;
					float _Type;
					float _LaserPos;
					//顶点函数
					v2f vert(appdata v)
					{
						v2f o;
						UNITY_INITIALIZE_OUTPUT(v2f, o);
						o.vertex = UnityObjectToClipPos(v.vertex);
						o.uv = v.uv;
						//世界法线
						float3 worldNormal = UnityObjectToWorldNormal(v.normal);
						//世界切线
						float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
						//世界副切线
						float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
						//世界坐标
						float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

						//构建变换矩阵
						//z轴是法线方向(n)，x轴是切线方向(t)，y轴可由法线和切线叉积得到，也称为副切线（bitangent, b）
						o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
						o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
						o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
						return o;
					}

					fixed4 frag(v2f i) : SV_Target
					{
						//获取法线贴图
						float4 Normaltex = tex2D(_BumpMap, i.uv);
						//法线贴图0~1转-1~1
						float3 tangentNormal = UnpackNormal(Normaltex);
						//乘以凹凸系数
						tangentNormal.xy *= _BumpScale;
						//向量点乘自身算出x2+y2，再求出z的值
						tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
						//向量变换只需要3*3
						float3x3 T2WMatrix = float3x3(i.T2W0.xyz,i.T2W1.xyz,i.T2W2.xyz);
						//法线从切线空间到世界空间
						float3 worldNormal = mul(T2WMatrix,tangentNormal);

						//获取顶点世界坐标
						float3 WordPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
						//摄像机方向
						fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - WordPos);

						float faceRatio = max(0, dot(viewDir, worldNormal) + _LaserPos);

						faceRatio = pow(1 - abs(saturate(faceRatio) * 2 - 1), _LaserRange)* _LaserOffset;

						//表面反射方向
						fixed3 reflectDir = reflect(-viewDir, worldNormal);


						float3 _CubeMapColor = 1;

						if (_Type == 0)
						{
							//多清晰度读取环境求
							_CubeMapColor.r = texCUBElod(_CubeMap, fixed4(reflectDir.x + faceRatio, reflectDir.y, reflectDir.z, _CubeMapMipLevel));
							_CubeMapColor.g = texCUBElod(_CubeMap, fixed4(reflectDir.x, reflectDir.y, reflectDir.z, _CubeMapMipLevel));
							_CubeMapColor.b = texCUBElod(_CubeMap, fixed4(reflectDir.x, reflectDir.y + faceRatio, reflectDir.z , _CubeMapMipLevel));
						}
						else if (_Type == 1)
						{
							//多清晰度读取环境求
							_CubeMapColor.r = texCUBElod(_CubeMap, fixed4(reflectDir.x , reflectDir.y + faceRatio, reflectDir.z, _CubeMapMipLevel));
							_CubeMapColor.g = texCUBElod(_CubeMap, fixed4(reflectDir.x, reflectDir.y , reflectDir.z, _CubeMapMipLevel));
							_CubeMapColor.b = texCUBElod(_CubeMap, fixed4(reflectDir.x + faceRatio, reflectDir.y, reflectDir.z , _CubeMapMipLevel));
						}


						//颜色输出
						_CubeMapPow = 1 - _CubeMapPow;
						return saturate(fixed4(pow(saturate(_CubeMapColor - _CubeMapPow), _CubeMapRange), 1));
					}
					ENDCG

				}
		}
}