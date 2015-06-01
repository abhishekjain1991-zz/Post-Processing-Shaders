Shader "Custom/WaveEffect" {
Properties {
	_EncDepthNormalTex ("Encoded Depth/Normal Map", 2D) = "white" {}
		_OriginalImageTex ("Original Image", 2D) = "white" {}
		//_BaseC ("Base", Float) = 4
		_BaseC ("Base", Range(0.001,5)) =4
		_Speed ("Speed", Float) = 10.0
		_Amplitude ("Amplitude", Float) = 0.01
	}
		
    SubShader {
    
    Tags { "RenderType"="Opaque" }
	LOD 300
	
        Pass {
        	CGPROGRAM
			#include "UnityCG.cginc"

            #pragma vertex vert_fancypostproctest
            #pragma fragment frag_fancypostproctest
           
           	uniform sampler2D _EncDepthNormalTex;
           	uniform sampler2D _OriginalImageTex;
           		
           	uniform float4 _CameraData;
           	uniform int _BaseC;
			float _Speed;
				float _Amplitude;
           	
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};
 
            v2f vert_fancypostproctest(appdata_t v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				return o;
			}

     		float4 frag_fancypostproctest(v2f input,
     							  float4 screenPos : WPOS) : COLOR {
     	     	float4 encDepthNormal = tex2D(_EncDepthNormalTex, input.texcoord);
     	     	float4 originalImage = tex2D(_OriginalImageTex, input.texcoord);
     	     	
     	     	float3 normalVS;
     		    float z01mapped;
     		   
     		    DecodeDepthNormal(encDepthNormal, z01mapped, normalVS);
				normalVS = normalize(normalVS);
				
				// _CameraData.z = far - near; _CameraData.w = near;
     		 	float zRecon = z01mapped * _CameraData.z + _CameraData.w;						   	
				float2 xy_minus1to1 = (2 * screenPos.xy / _ScreenParams.xy) - 1;
				float2 xyRecon = xy_minus1to1 * zRecon * _CameraData.xy;
				float3 posVS = float3(xyRecon,zRecon);
				
				
     		    
				input.texcoord.x += sin(_Time.y + input.texcoord.x * _Speed+((posVS.z)/2)) * _Amplitude;
				input.texcoord.y += cos(_Time.y + input.texcoord.y * _Speed+((posVS.z)/2)) * _Amplitude;
				float4 col = tex2D(_OriginalImageTex, input.texcoord);
				return col;
	
     	    }

            ENDCG
        }
    }
}



