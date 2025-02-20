vec2 map(vec3 p) {
    //plane
    float planeDist = fPlane(p, vec3(0, 1, 0), 12.0);
    float planeID = 6.0;
    vec2 plane = vec2(planeDist, planeID);

    //sphere
    float sphereDist = fSphere(p, 5.0 + fDisplace(p));
    float sphereID = 1.0;
    vec2 sphere = vec2(sphereDist, sphereID);

    //manipulation operators
    pMirrorOctant(p.xz, vec2(50, 50));
    p.x = -abs(p.x);
    pMod1(p.z, 100);

    //wall 
    float wallDist = fBox2Cheap(p.xy, vec2(2, cubeSize));
    float wallID = 5.0;
    vec2 wall = vec2(wallDist, wallID);

    pModPolar(p.xz, 8.0);

    //cylinder
    float cylinderDist = fCylinder(p, 17, 20);
    float cylinderID = 5.0;
    vec2 cylinder = vec2(cylinderDist, cylinderID);

    //box
    vec3 pc = p;
    pc.x -= 13.7;
    float boxDist = fBox(pc.xyz, vec3(3,22,3));
    float boxID = 5.0;
    vec2 box = vec2(boxDist, boxID);

    //result
    vec2 res;
    res = fOpUnionID(cylinder, wall);
    res = fOpUnionID(res, box);
    res = fOpUnionID(res, plane);
    res = fOpUnionID(res, sphere);
    return res;
}