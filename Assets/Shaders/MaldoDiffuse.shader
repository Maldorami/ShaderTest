﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Maldo/Diffuse" {
	Properties{
		_Color("Diffuse Material Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		// pass for first light source

		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"

		uniform float4 _LightColor0;
	// color of light source (from "Lighting.cginc")

	uniform float4 _Color; // define shader property for shaders

	struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};
	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 col : COLOR;
	};

	sampler2D _MainTex;

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = unity_ObjectToWorld;
		float4x4 modelMatrixInverse = unity_WorldToObject;

		float3 normalDirection = normalize(
			mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
		float3 lightDirection;
		float attenuation;

		float4 texColor = tex2Dlod(_MainTex, float4(input.uv, 0, 0));

		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		}
		else // point or spot light
		{
			float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
				- mul(modelMatrix, input.vertex).xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}

		float3 diffuseReflection =
			attenuation * _LightColor0.rgb * _Color.rgb * texColor
			* max(0.0, dot(normalDirection, lightDirection));

		output.col = float4(diffuseReflection, 1.0);
		output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
		return output;
	}

	float4 frag(vertexOutput input) : COLOR
	{
		return input.col;
	}

		ENDCG
	}

		Pass{
		Tags{ "LightMode" = "ForwardAdd" }
		// pass for additional light sources
		Blend One One // additive blending 

		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"

		uniform float4 _LightColor0;
	// color of light source (from "Lighting.cginc")

	uniform float4 _Color; // define shader property for shaders

	struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};
	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 col : COLOR;
	};

	sampler2D _MainTex;

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = unity_ObjectToWorld;
		float4x4 modelMatrixInverse = unity_WorldToObject;

		float3 normalDirection = normalize(
			mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
		float3 lightDirection;
		float attenuation;

		float4 texColor = tex2Dlod(_MainTex, float4(input.uv, 0, 0));

		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		}
		else // point or spot light
		{
			float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
				- mul(modelMatrix, input.vertex).xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}

		float3 diffuseReflection =
			attenuation * _LightColor0.rgb * _Color.rgb * texColor
			* max(0.0, dot(normalDirection, lightDirection));

		output.col = float4(diffuseReflection, 1.0);
		output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
		return output;
	}

	float4 frag(vertexOutput input) : COLOR
	{
		return input.col;
	}

		ENDCG
	}
	}
		Fallback "Diffuse"
}