Shader "Maldo/EasterEggShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		_rotateSpeed("Rotate Speed", Range(0,1)) = .5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				#pragma multi_compile_fog

				#include "UnityCG.cginc"


				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					float4 vertex : SV_POSITION;
					float3 normal : NORMAL;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _rotateSpeed;

				float4 RotateAroundYInDegrees(float4 vertex, float degrees) {
					float alpha = _Time.y * degrees * UNITY_PI;
					float sina, cosa;
					sincos(alpha, sina, cosa);

					float2x2 m = float2x2(cosa, sina, sina, -cosa);
					return float4(mul(m, vertex.yz), vertex.xw).xzyw;
				}

				v2f vert(appdata_base v)
				{
					v2f o;
					float4 tweenValue = float4(v.vertex.xyz * (sin(_Time.w) + 5) / 5, v.vertex.w);
					float4 asd = mul(UNITY_MATRIX_MVP, RotateAroundYInDegrees(tweenValue, _rotateSpeed));

					o.vertex = asd;
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.normal = v.normal;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv) * (sin(_Time.w) + 1.7) / 1.7;
					// apply fog
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
			ENDCG
		}
		}
}
