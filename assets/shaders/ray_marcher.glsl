#[compute]
#version 450

//Dont forget to change the 'set' qualifiers for the buffers!


//Compute shader for the ray marcher.
//Adapted from Sebastian Lague's raymarching implementation for Unity: 
//https://github.com/SebLague/Ray-Marching/blob/master/Assets/Scripts/SDF/Raymarching.compute

//Work group size
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

const float maxDst = 80.0;
const float epsilon = 0.001;
const float shadowBias = epsilon*50.0;
const int maxSteps = 300;


struct Shape{

    int shapeType;
    vec4 color;
    vec4 size;
    mat4 transform;
    vec4 hyperInfo; //Vector4(XW_degrees, YW_degrees, ZW_degrees, W_pos)

};

struct Ray{

    vec3 origin;
    vec3 direction;

};

//Camera data buffer
layout(set = 0, binding = 0, std430) restrict readonly buffer CameraBuffer{

    mat4 transform;
    mat4 projectionMatrixInverse;

}
camera;

//Shape list buffer
layout(set = 0, binding = 1, std430) restrict readonly buffer ShapesBuffer{

    int numShapes;
    Shape shapeList[];

}
shapes;

//Screen for dimensions
layout(set = 0, binding = 2, std430) restrict readonly buffer ScreenBuffer{

    float width;
    float height;

}
screen;


//Output image
precision highp image2D;
layout(rgba32f, binding = 3) uniform writeonly image2D outputTexture;


vec4 Combine(float dstA, float dstB, vec3 colA, vec3 colB){

    //Sebastian's code is structured in a way that would let
    //this method perform blending, cutting and masking on
    //the shapes thrown in here. idk if we're gonna use allat tho...


    //In any case, what this does for the time being is return the closest of two distances,
    //and returning the corresponding color also.

    float dst = dstA;
    vec3 col = colA;

    if(dstB<dstA){

        dst = dstB;
        col = colB;

    }

    return vec4(col, dst);

}

float cubeDistance(vec3 point, Shape shape){

    mat4 inverseMat = inverse(shape.transform);
    point = (inverseMat * vec4(point, 1.0)).xyz;


    //SDF of a cube!

    vec3 vectorDistance = abs(point) - shape.size.xyz;
    // ^ is a vector that points from the point parameter to the surface of the shape, if we return:
    return length(max(vectorDistance,0.0)) + min(max(vectorDistance.x, max(vectorDistance.y,vectorDistance.z)),0.0);

}

float hyperCubeDistance(vec4 point, Shape shape){

    mat4 inverseMat = inverse(shape.transform);
    point.xyz = (inverseMat * vec4(point.x, point.y, point.z, 1.0)).xyz; //3d transform application

    point.w += shape.hyperInfo.w;
    point.xw *= mat2(vec2(cos(shape.hyperInfo.x), sin(shape.hyperInfo.x)), vec2(-sin(shape.hyperInfo.x), cos(shape.hyperInfo.x)));
    point.zw *= mat2(vec2(cos(shape.hyperInfo.z), -sin(shape.hyperInfo.z)), vec2(sin(shape.hyperInfo.z), cos(shape.hyperInfo.z)));
	point.yw *= mat2(vec2(cos(shape.hyperInfo.y), -sin(shape.hyperInfo.y)), vec2(sin(shape.hyperInfo.y), cos(shape.hyperInfo.y)));


    vec4 vectorDistance = abs(point) - shape.size;
    return length(max(vectorDistance, 0.0)) + min(max(vectorDistance.x, max(vectorDistance.y, max(vectorDistance.z, vectorDistance.w))), 0.0);
    //return min(max(dist.x, max(dist.y, max(dist.z, dist.w))), 0.0f) + length(max(dist, 0.0f));
}


Ray createRay(vec3 origin, vec3 direction){

    Ray ray;
    ray.origin = origin;
    ray.direction = direction;
    return ray;

}

Ray createCamRay(vec2 uv){
    // calculate the origin and orientation of a ray to instance one and return it

    vec3 origin = vec3(camera.transform[3]);
    //Column #4 of the transformation matrix ought to contain the translation vector

    vec3 direction = (camera.projectionMatrixInverse*vec4(uv, 0.0, 1)).xyz;
    direction = normalize((camera.transform * vec4(direction, 0.0)).xyz);
    //this matrix tomfoolery allows to orient the rays in 3d WorldSpace to account for rotations and stuff
    //this actually saved my life and comes from: https://github.com/nekotogd/Raytracing_Godot4/blob/master/BasicComputeShader/RayTracer.glsl


    return createRay(origin, direction);

}

float getShapeDistance(Shape shape, vec3 point){
    //Returns the distance between a Shape and a point

    vec4 hyperPoint = vec4(point, 0.0);

    switch (shape.shapeType){
    case 0:
        return cubeDistance(point, shape);
    case 1:
        return hyperCubeDistance(hyperPoint, shape);
    }

    return maxDst;

}

vec4 sceneInfo(vec3 camPos){
    //Returns a vector whose first 3 components make up an RGB vector
    //The last component is the distance from camPos to the scene.

    float globalDst = maxDst;
    vec3 globalCol = vec3(1.0);

    for(int i = 0; i<shapes.numShapes; i++){

        Shape shape = shapes.shapeList[i];
        
        float localDst = getShapeDistance(shape, camPos);
        vec3 localCol = (shape.shapeType == 0) ? vec3(-1) : shape.color.xyz;

        vec4 combined = Combine(globalDst, localDst, globalCol, localCol);

        globalCol = combined.xyz;
        globalDst = combined.w;

    }

    return vec4(globalCol, globalDst);


}

vec3 getNormal(vec3 p) {
    float x = sceneInfo(vec3(p.x+epsilon,p.y,p.z)).w - sceneInfo(vec3(p.x-epsilon,p.y,p.z)).w;
    float y = sceneInfo(vec3(p.x,p.y+epsilon,p.z)).w - sceneInfo(vec3(p.x,p.y-epsilon,p.z)).w;
    float z = sceneInfo(vec3(p.x,p.y,p.z+epsilon)).w - sceneInfo(vec3(p.x,p.y,p.z-epsilon)).w;
    return normalize(vec3(x,y,z));
}

vec3 blinnPhong(vec3 position, // hit point
                vec3 lightPosition, // position of the light source
                vec3 ambientCol, // ambient color
                vec3 lightCol, // light source color
                float ambientCoeff, // scale ambient contribution
                float diffuseCoeff, // scale diffuse contribution
                float specularCoeff, // scale specular contribution
                float specularExponent // how focused should the shiny spot be
){
    vec3 normal = getNormal(position);
    vec3 toEye = normalize(vec3(camera.transform[3]) - position);
    vec3 toLight = normalize(lightPosition - position);
    vec3 reflection = reflect(-toLight, normal);
     
    vec3 ambientFactor = ambientCol * ambientCoeff;
    vec3 diffuseFactor = diffuseCoeff * lightCol * max(0.0, dot(normal, toLight));
    vec3 specularFactor = lightCol * pow(max(0.0, dot(toEye, reflection)), specularExponent)
                     * specularCoeff;
     
    return ambientFactor + diffuseFactor + specularFactor;
}



//RENDERING
const float globalAmbient = 0.1; // how strong is the ambient lightning
const float globalDiffuse = 1.0; // how strong is the diffuse lightning
const float globalSpecular = 1.0; // how strong is the specular lightning
const float globalSpecularExponent = 64.0; // how focused is the shiny spot
const vec3 lightPos = vec3(-2.0,6.0, 3.0); // position of the light source
const vec3 lightColor = vec3(0.9, 0.9, 0.68);//vec3(0.9, 0.9, 0.68); // color of the light source

//Gooch!!!
float shininess= 64.0;
vec3 warm_col = vec3(0.3, 0.3, 0.0);
vec3 cool_col = vec3(0.0, 0.0, 0.55);
float alpha = 0.25;
float beta = 0.5;

//Everything you need to know comes from: https://users.cs.northwestern.edu/~ago820/SIG98/gooch98.pdf
vec3 daGooch(vec3 ray_pos, // hit point
            vec3 light_pos, // position of the light source
            vec3 ambient_col, // ambient color
            vec3 light_col // light source color
){

    //Commented lines are just random stuff I tried while trying to figure things out... gotta clean it soon c:
    vec3 normal = getNormal(ray_pos);
    vec3 light_dir = normalize(light_pos - ray_pos);
    vec3 view_dir = normalize(vec3(camera.transform[3]) - ray_pos);
    //vec3 half_angle = normalize(light_dir + view_dir);

    //float ndoth = dot(half_angle, normal);
    vec3 reflection_dir = normalize(reflect(-light_dir, normal));
    float specular_strength = pow(max(0,dot(view_dir, reflection_dir)),shininess);//pow(ndoth, shininess);

    float gooch_coeff = (1.0 + dot(light_dir, normal))/2.0;
    //vec3 gooch = mix(warm_col, cool_col, gooch_coeff);

    vec3 kCool = cool_col + alpha * ambient_col;
    vec3 kWarm = warm_col + beta * ambient_col;

    vec3 goochDiffuse = gooch_coeff*kWarm + (1-gooch_coeff)*kCool;

    vec3 color = specular_strength + (1.0-specular_strength)*goochDiffuse;
    //color = 1.0*ambient_col + 0.8*gooch + vec3(1.0)*0.9*specular_strength;

    return color;
}

//Raymarch method, finds whether the raycast hits something or not. In case it does, it returns the color that should be rendered in the surface
//Right now we could use BlinnPhong Shading, or a rough implementation of the Gooch method to determine the color of the pixel.
//Added a simple edge detection for the render, it comes from https://www.shadertoy.com/view/wtcGDj
//Should come up with something better for that, for now using small edge width doesn't ruin it that much
vec4 raymarch(Ray ray){
    float rayDst = 0.0; //Distance traveled by the ray
    int marchSteps = 0; //Number o' steps

    bool hit = false;
    bool edge = false;
    float last_dist_eval = maxDst;

    while (rayDst < maxDst){

        //Every step,
        marchSteps++;

        vec3 rayPos = ray.origin + ray.direction * rayDst;

        //Get scene information (color and distance at a point)
        vec4 sceneInfo = sceneInfo(rayPos);
        
        //Distance from point to scene
        float dst = sceneInfo.w;

        if(dst <= epsilon){//Hit!!!
            //vec3 color = blinnPhong(rayPos, lightPos, sceneInfo.rgb, lightColor, globalAmbient, globalDiffuse, globalSpecular, globalSpecularExponent);
            vec3 color = daGooch(rayPos, lightPos, sceneInfo.rgb, lightColor);
            return (sceneInfo.r == -1)? vec4(0.0) : vec4(color,1.0);
        }
        
        //If the distance starts growing after it was diminishing, it means we're on the edge of a shape.
        if((sceneInfo.r != -1) && dst > last_dist_eval && dst <= epsilon*60){
            return vec4(vec3(0.3)*sceneInfo.rgb,1.0);
        }

        last_dist_eval = dst;

        rayDst += dst;

    }
    return vec4(0.0); //If we never hit anything during the cycle, I'm just guessing it's the sky
}

void main(){

    //Get current pixel thru invocation ID 
    ivec2 pixelCoords = ivec2(gl_GlobalInvocationID.xy);

  
    //Check out of bounds  (very important)
    if (pixelCoords.x >= int(screen.width) || pixelCoords.y >= int(screen.height)) {
        return;
    }

    //UV!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 
    vec2 uv = pixelCoords / vec2(screen.width, screen.height) * 2.0 - 1.0;
    uv = vec2(uv.x, -uv.y);

    //Ray
    Ray ray = createCamRay(uv);
    vec4 outputCol = raymarch(ray);

    imageStore(outputTexture, pixelCoords, outputCol);
    

}
