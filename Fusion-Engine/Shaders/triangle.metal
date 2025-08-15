#include <metal_stdlib>
using namespace metal;

struct VSOut {
    float4 position [[position]];
    float4 color;
};

vertex VSOut v_main(uint vid [[vertex_id]]) {
    float2 pos[3] = { float2(-0.8,-0.8), float2(0.0,0.8), float2(0.8,-0.8) };
    float4 col[3] = { float4(1,0,0,1), float4(0,1,0,1), float4(0,0.5,1,1) };
    VSOut o;
    o.position = float4(pos[vid], 0, 1);
    o.color = col[vid];
    return o;
}

fragment float4 f_main(VSOut in [[stage_in]]) {
    return in.color;
}


