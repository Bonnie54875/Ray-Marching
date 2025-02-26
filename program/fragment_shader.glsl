#version 430 core
#include hg_sdf.glsl
layout (location = 0) out vec4 fragColor;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;
uniform float u_scroll;
uniform sampler2D u_texture1;
uniform sampler2D u_texture2;

const float FOV = 1.0;
const int MAX_STEPS = 50;
const float MAX_DIST = 500;
const float EPSILON = 0.001;

float cubeSize = 12.0;
float cubeScale = 0.5 / cubeSize;

vec3 triPlanar(sampler2D tex, vec3 p, vec3 normal) {
    normal = abs(normal);
    return (texture(tex, p.xy * 0.5 + 0.5) * normal.z +
            texture(tex, p.xz * 0.5 + 0.5) * normal.y +
            texture(tex, p.yz * 0.5 + 0.5) * normal.x).rgb;
}

float fDisplace(vec3 p) {
    pR(p.xz, 3 * u_time);
    return (sin(p.x + 3.0 * u_time) *  sin(p.y + 3.0 * u_time)) * sin(p.z + 3.0 * u_time);
}

vec2 fOpUnionID(vec2 res1, vec2 res2) {
    return (res1.x < res2.x) ? res1 : res2;
}

#include map.glsl
#include material.glsl

vec2 rayMarch(vec3 ro, vec3 rd) {
    vec2 hit, object;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + object.x * rd;
        hit = map(p);
        object.x += hit.x;
        object.y = hit.y;
        if (abs(hit.x) < EPSILON || object.x > MAX_DIST) break;
    }
    return object;
}

vec3 getNormal(vec3 p) {
    vec2 e = vec2(EPSILON, 0.0);
    vec3 n = vec3(map(p).x) - vec3(map(p - e.xyy).x, map(p - e.yxy).x, map(p - e.yyx).x);
    return normalize(n);
}

float getSoftShadow(vec3 p, vec3 lightPos) {
    float res = 1.0;
    float dist = 0.1;
    float lightSize = 0.03;
    for (int i = 0; i < MAX_STEPS; i++) {
        float hit = map(p + lightPos * dist).x;
        res = min(res, hit / (dist * lightSize));
        dist += hit;
        if (hit < 0.0001 || dist > 60.0) break;
    }
    return clamp(res, 0.0, 1.0);
}


vec3 getLight(vec3 p, vec3 rd, float id) {
    vec3 lightPos = vec3(20.0, 55.0, -25.0);
    vec3 L = normalize(lightPos - p);
    vec3 N = getNormal(p);
    vec3 V = -rd;
    vec3 R = reflect(-L, N);

    vec3 color = getMaterial(p, id, N);

    vec3 specColor = vec3(0.6, 0.5, 0.4);
    vec3 specular = 1.3 * specColor * pow(clamp(dot(R, V), 0.0, 1.0), 10.0);
    vec3 diffuse = 0.9 * color * clamp(dot(L, N), 0.0, 1.0);
    vec3 ambient = 0.05 * color;
    vec3 fresnel = 0.15 * color * pow(1.0 + dot(rd, N), 3.0);

    //shadows
    float shadow = getSoftShadow(p + N * 0.02, normalize(lightPos));
    //back
    vec3 back = 0.05 * color * clamp(dot(N, -L), 0.0, 1.0);

    return (back + ambient + fresnel) + (specular + diffuse) * shadow;
}

mat3 getCam(vec3 ro, vec3 lookAt) {
    vec3 camF = normalize(vec3(lookAt - ro));
    vec3 camR = normalize(cross(vec3(0, 1, 0), camF));
    vec3 camU = cross(camF, camR);
    return mat3(camR, camU, camF);
}

void mouseControl(inout vec3 ro) {
    vec2 m = u_mouse / u_resolution;
    pR(ro.yz, m.y * PI * 0.4 - 0.4);
    pR(ro.xz, m.x * TAU);
}

vec3 render(vec2 uv) {
    vec3 col = vec3(0);
    vec3 background = vec3(0.5, 0.8, 0.9);

    vec3 ro = vec3(36.0, 70.0, -36.0) / u_scroll;
    mouseControl(ro);

    vec3 lookAt = vec3(0, 1, 0);
    vec3 rd = getCam(ro, lookAt) * normalize(vec3(uv, FOV));

    vec2 object = rayMarch(ro, rd);

    if (object.x < MAX_DIST) {
        vec3 p = ro + object.x * rd;
        col += getLight(p, rd, object.y);
        // fog
        col = mix(col, background, 1.0 - exp(-1e-7 * object.x * object.x * object.x));
    } else {
        col += background - max(0.9 * rd.y, 0.0);
    }
    return col;
}

/*vec2 getUV(vec2 offset) {
    return (2.0 * (gl_FragCoord.xy + offset) - u_resolution.xy) / u_resolution;
}*/


void main() {
    vec2 uv = (2.0 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y;

    vec3 color = render(uv);
    //gamma correction
    color = pow(color, vec3(0.4545));
    fragColor = vec4(color, 1.0);
}
