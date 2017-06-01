#warning Upgrade NOTE : unity_Scale shader variable was removed; replaced 'unity_Scale.w' with '1.0'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Maldo/CurvedWorld"
{
	Properties{
		_mainColor("Color", Color) = (0,0,0,0)
		_mainTexture("Texture", 2D) = "white" {}


		_OffsetAnimX("Speed on X", Float) = 0
		_OffsetAnimY("Speed on Y", Float) = 0

	}
		SubShader
		{
				Tags{ "RenderType" = "Opaque" "DisableBatching" = "True" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag			
				#include "UnityCG.cginc"
				#include "UnityLightingCommon.cginc"

				struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

				fixed4 _mainColor;
				sampler2D _MainTex;
				float4 _MainTex_ST;

				float _OffsetAnimX;
				float _OffsetAnimY;

				uniform int _bend;
				uniform float _HORIZONOFFSET;
				uniform float _ATTENUATE;
				uniform float _SPREAD;

				struct v2f
				{
					float4 pos: SV_POSITION;
					float2 uv: TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float3 normal : NORMAL;
					fixed4 diff : COLOR;
				};

				float4 Effect(float4 v) {
					float4 t = mul(unity_ObjectToWorld, v);

					float disX = max(0, abs(_WorldSpaceCameraPos.x + _HORIZONOFFSET - t.x) - _SPREAD);
					t.y += disX * disX * _ATTENUATE;
					float disZ = max(0, abs(_WorldSpaceCameraPos.z + _HORIZONOFFSET - t.z) - _SPREAD);
					t.y += disZ * disZ * _ATTENUATE;



					t.xyz = mul(unity_WorldToObject, t) * 1.0;
					return t;
				}

				v2f vert(appdata v)
				{
					v2f o;
					if (_bend != 1)
					{
						o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					}
					else
					{
						o.pos = mul(UNITY_MATRIX_MVP, Effect(v.vertex));
					}


					o.uv = TRANSFORM_TEX(v.uv, _MainTex) + float2(_Time.y * _OffsetAnimX, _Time.y * _OffsetAnimY);

					UNITY_TRANSFER_FOG(o, o.vertex);

					o.normal = v.normal;
					// get vertex normal in world space
					half3 worldNormal = UnityObjectToWorldNormal(-v.normal);
					// standard diffuse (Lambert) lighting
					half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
					// factor in the light color
					o.diff = nl * _LightColor0;

					return o;
				}



				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture				
					fixed4 col = tex2D(_MainTex, i.uv);
					// apply fog
					UNITY_APPLY_FOG(i.fogCoord, col);
					col *= i.diff;

					col *= _mainColor;
					
					return col;
				}
				ENDCG
			}
		}
}
