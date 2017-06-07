Shader "Maldo/Offset Animation"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}

		_AlphaModifier("Alpha", Range(0,1)) = 1
		_OffsetAnimX("Speed on X", Float) = 0
		_OffsetAnimY("Speed on Y", Float) = 0

	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				fixed4 diff : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _OffsetAnimX;
			float _OffsetAnimY;
			half _AlphaModifier;
			float4 _Color;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex) + float2(_Time.y * _OffsetAnimX, _Time.y * _OffsetAnimY);

				UNITY_TRANSFER_FOG(o,o.vertex);

				o.normal = v.normal;

				// get vertex normal in world space
				half3 worldNormal = UnityObjectToWorldNormal(-v.normal);
				// standard diffuse (Lambert) lighting
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color
				o.diff = nl * _LightColor0;
								
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture				
				fixed4 col = tex2D(_MainTex, i.uv );
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				col *= i.diff;

				col *= _Color;

				col.a = _AlphaModifier;
				
				return col;
			}
			ENDCG
		}
	}
}
