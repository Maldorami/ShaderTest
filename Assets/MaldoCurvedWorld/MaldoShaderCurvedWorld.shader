Shader "Maldo/CurvedWorld"
{
	Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Pass
	{
		Tags{ "RenderType" = "Opaque" "LightMode" = "ForwardBase" }


		CGPROGRAM
		#pragma vertex vert addshadow
		#pragma fragment frag
		#pragma multi_compile_fog			
		#include "UnityCG.cginc"
		//#include "Lighting.cginc"

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
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _Color;

	uniform int _bend;
	uniform float _HORIZONOFFSETX;
	uniform float _HORIZONOFFSETZ;
	uniform float _ATTENUATE;
	uniform float _SPREAD;

	uniform float4 _LightColor0;

	float4 Effect(float4 v) {
		float4 t = mul(unity_ObjectToWorld, v);
		float disX = max(0, abs(_HORIZONOFFSETX - t.x) - _SPREAD);
		t.y += disX * disX * _ATTENUATE;
		float disZ = max(0, abs( _HORIZONOFFSETZ - t.z) - _SPREAD);
		t.y += disZ * disZ * _ATTENUATE;
		t.xyz = mul(unity_WorldToObject, t) * 1.0;
		return t;
	}

	v2f vert(appdata v)
	{
		v2f o;

		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		float3 v0 = o.pos;
		float3 v1 = v0 + float3(0.05, 0, 0); //+X
		float3 v2 = v0 + float3(0, 0, 0.05); //+Z

		if (_bend == 1)
		{
			o.pos = mul(UNITY_MATRIX_MVP, Effect(v.vertex));
			v1 = o.pos + float3(0.05, 0, 0);
			v2 = o.pos + float3(0, 0, -0.05);
		}

		float3 vna = normalize(cross(v2 - v0, v1 - v0));
		float3 vn = mul(unity_WorldToObject, vna);
		o.normal = vn;


		o.uv = mul(unity_ObjectToWorld, v.vertex);
		o.uv.xy = v.uv;

		UNITY_TRANSFER_FOG(o, o.vertex);

		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed4 col = tex2D(_MainTex, i.uv);
		UNITY_APPLY_FOG(i.fogCoord, col);

		float4x4 modelMatrix = unity_ObjectToWorld;
		float4x4 modelMatrixInverse = unity_WorldToObject;

		float3 normalDirection = normalize(
			mul(float4(i.normal, 0.0), modelMatrixInverse).xyz);

		float3 lightDirection;
		float attenuation;

		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		}
		else // point or spot light
		{
			float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
				- mul(modelMatrix, i.pos).xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}

		float3 diffuseReflection =
			attenuation * _LightColor0.rgb * _Color.rgb
			* max(0.0, dot(normalDirection, lightDirection));

		col *= float4(diffuseReflection, 1.0);
		col *= _Color;

		return col;
	}
		ENDCG
	}
			Pass{
					Tags{ "LightMode" = "ForwardAdd" }
					// pass for additional light sources
					Blend One One // additive blending 

				CGPROGRAM
#pragma vertex vert addshadow
#pragma fragment frag
#pragma multi_compile_fog			
#include "UnityCG.cginc"
				//#include "Lighting.cginc"

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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;

			uniform int _bend;
			uniform float _HORIZONOFFSETX;
			uniform float _HORIZONOFFSETZ;
			uniform float _ATTENUATE;
			uniform float _SPREAD;

			uniform float4 _LightColor0;

			float4 Effect(float4 v) {
				float4 t = mul(unity_ObjectToWorld, v);
				float disX = max(0, abs(_HORIZONOFFSETX - t.x) - _SPREAD);
				t.y += disX * disX * _ATTENUATE;
				float disZ = max(0, abs(_HORIZONOFFSETZ - t.z) - _SPREAD);
				t.y += disZ * disZ * _ATTENUATE;
				t.xyz = mul(unity_WorldToObject, t) * 1.0;
				return t;
			}

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				float3 v0 = o.pos;
				float3 v1 = v0 + float3(0.05, 0, 0); //+X
				float3 v2 = v0 + float3(0, 0, 0.05); //+Z

				if (_bend == 1)
				{
					o.pos = mul(UNITY_MATRIX_MVP, Effect(v.vertex));
					v1 = o.pos + float3(0.05, 0, 0);
					v2 = o.pos + float3(0, 0, -0.05);
				}

				float3 vna = normalize(cross(v2 - v0, v1 - v0));
				float3 vn = mul(unity_WorldToObject, vna);
				o.normal = vn;


				o.uv = mul(unity_ObjectToWorld, v.vertex);
				o.uv.xy = v.uv;

				UNITY_TRANSFER_FOG(o, o.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
			UNITY_APPLY_FOG(i.fogCoord, col);

			float4x4 modelMatrix = unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;

			float3 normalDirection = normalize(
				mul(float4(i.normal, 0.0), modelMatrixInverse).xyz);

			float3 lightDirection;
			float attenuation;

			if (0.0 == _WorldSpaceLightPos0.w) // directional light?
			{
				attenuation = 1.0; // no attenuation
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			}
			else // point or spot light
			{
				float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
					- mul(modelMatrix, i.pos).xyz;
				float distance = length(vertexToLightSource);
				attenuation = 1.0 / distance; // linear attenuation 
				lightDirection = normalize(vertexToLightSource);
			}

			float3 diffuseReflection =
				attenuation * _LightColor0.rgb * _Color.rgb
				* max(0.0, dot(normalDirection, lightDirection));

			col *= float4(diffuseReflection, 1.0);
			col *= _Color;

			return col;
			}
				ENDCG
	}
	}
		Fallback "Diffuse"
}