Shader "Maldo/CurvedWorld"
{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		//_AlphaModifier("Alpha", Range(0,1)) = 1
	}
		SubShader
		{
			Tags{ "RenderType" = "Opaque" "LightMode"="ForwardBase" }
			

			Pass
			{
				CGPROGRAM
				#pragma vertex vert addshadow
				#pragma fragment frag
				#pragma multi_compile_fog			
				#include "UnityCG.cginc"
				#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 uv: TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float3 normal : NORMAL;
				fixed4 diff : COLOR;
			};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				//half _AlphaModifier;
				float4 _Color;

				uniform int _bend;
				uniform float _HORIZONOFFSET;
				uniform float _ATTENUATE;
				uniform float _SPREAD;

				

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

					o.uv = mul(unity_ObjectToWorld, v.vertex);
					o.uv.xy = v.uv;

					UNITY_TRANSFER_FOG(o, o.vertex);

					o.normal = v.normal;

					// get vertex normal in world space
					float3 worldNormal = UnityObjectToWorldNormal(v.normal) * v.vertex;
					// standard diffuse (Lambert) lighting
					half nl = max(0, mul(worldNormal,- _WorldSpaceLightPos0.xyz));

					o.diff = nl + _LightColor0 * UNITY_LIGHTMODEL_AMBIENT;

					return o;
				}



				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					UNITY_APPLY_FOG(i.fogCoord, col);

					col *= i.diff;
					col *= _Color;

					return col;
				}
				ENDCG
			}
		}
}
