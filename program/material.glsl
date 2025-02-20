vec3 getMaterial(vec3 p, float id, vec3 normal) {
    vec3 m;
    switch (int(id)) {
        case 1:
        m = vec3(0.9, 0.0, 0.0); break;
        case 2:
        m = vec3(0.2 + 0.4 * mod(floor(p.x) + floor(p.z), 2.0)); break;
        case 3:
        m = vec3(0.7, 0.8, 0.9); break;
        case 4:
        m = vec3(0, 0.8, 0); break;
        case 5:
        m = triPlanar(u_texture1, p * cubeScale, normal); break; 
        case 6:
        m = triPlanar(u_texture2, p * cubeScale, normal); break; 
    }
    return m;
}