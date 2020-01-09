Shader "Custom/MaskedUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientTex ("Gradient Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uvg : TEXCOORD0;
                float2 uvm : TEXCOORD0;
            };

            struct v2f
            {
                // UV1 and UV2 are used by lightmapping
                float2 uv : TEXCOORD0;
                float2 uvg : TEXCOORD3;
                float2 uvm : TEXCOORD4;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GradientTex;
            float4 _GradientTex_ST;

            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvg = TRANSFORM_TEX(v.uvg, _GradientTex);
                o.uvm = TRANSFORM_TEX(v.uvm, _MaskTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 gradient = tex2D(_GradientTex, i.uvg);
                fixed mask = tex2D(_MaskTex, i.uvm).r;
                fixed4 result = lerp(col, gradient, mask);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, result);
                return result;
            }
            ENDCG
        }
    }
}
