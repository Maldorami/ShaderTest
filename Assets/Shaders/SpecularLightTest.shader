Shader "Maldo/SpecularVertex"
 {
      Properties {
        _MainTex ("Texture 1", 2D) = "white" {}
        _Ambient("Ambient Color",Color) = (0.3,0.3,0.3,1)
      }
      SubShader {
      Tags { "RenderType"="Opaque"}
      Pass {
           Tags { "LightMode" = "Vertex" }//otherwise no light related values will be filled

           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #include "UnityCG.cginc"
   
           sampler2D _MainTex;
           fixed4 _Ambient;
           half4 _MainTex_ST;
   
           struct v2f{
               fixed4 position: POSITION;
               half2 uv_MainTex:TEXCOORD0;
               fixed4 color: COLOR;
           };
   
           v2f vert (appdata_base ab) {
               v2f o;
    
               o.position = mul(UNITY_MATRIX_MVP,ab.vertex);
               o.uv_MainTex = TRANSFORM_TEX(ab.texcoord.xy , _MainTex);
    
               // per vertex light calc
               fixed3 lightDirection;
               fixed attenuation;
               // add diffuse
               if(unity_LightPosition[0].w == 0.0)//directional light
               {
                  attenuation = 1;
                  lightDirection = normalize(mul(unity_LightPosition[0]  ,UNITY_MATRIX_IT_MV).xyz);
               }
               else// point or spot light
               {
                  lightDirection = normalize(mul(unity_LightPosition[0],UNITY_MATRIX_IT_MV).xyz - ab.vertex.xyz);
                  attenuation = 1.0/(length(mul(unity_LightPosition[0],UNITY_MATRIX_IT_MV).xyz - ab.vertex.xyz)) * 0.5;
               }


               fixed3 normalDirction = normalize(ab.normal);
               fixed3 diffuseLight =  unity_LightColor[0].xyz * max(dot(normalDirction,lightDirection),0);

               // combine the lights (diffuse + ambient)
               o.color.xyz = diffuseLight * attenuation + _Ambient.xyz;

               return o;
           }
   
           fixed4 frag(v2f i):COLOR{
              fixed4 c = tex2D(_MainTex, i.uv_MainTex);   
              return  c * i.color;
           }
           ENDCG
      }
      }
Fallback "Mobile/Diffuse"
}
