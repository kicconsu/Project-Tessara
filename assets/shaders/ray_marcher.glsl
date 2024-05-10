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
const int maxSteps = 25;


struct Shape{

    int shapeType;
    vec4 color;
    vec4 size;
    mat4 transform;

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

    //return distance(point, center) - size[0];

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

    if(shape.shapeType == 0){
        return cubeDistance(point, shape);
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
        vec3 localCol = shape.color.xyz;

        vec4 combined = Combine(globalDst, localDst, globalCol, localCol);

        globalCol = combined.xyz;
        globalDst = combined.w;

    }

    return vec4(globalCol, globalDst);


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


    //The *thing*
    Ray ray = createCamRay(uv);
    float rayDst = 0.0; //Distance traveled by the ray
    int marchSteps = 0; //Number o' steps

    bool hit = false;

    while (rayDst < maxDst){

        //Every step,
        marchSteps++;

        vec3 rayPos = ray.origin + ray.direction * rayDst;

        //Get scene information (color and distance at a point)
        vec4 sceneInfo = sceneInfo(rayPos);
        
        //Distance from point to scene
        float dst = sceneInfo.w;

        if(dst <= epsilon){//Hit!!!

            //TODO: them lights and shadows mate....
            vec3 pixelCol = sceneInfo.rgb;

            float col = rayDst * 0.05;
            vec3 zBuffer = vec3(col);

            imageStore(outputTexture, pixelCoords, vec4(pixelCol, 1.0));

            hit = true;

            break;

        }

        rayDst += dst;

    }

    float col = rayDst * 0.05;
    vec3 zBuffer = vec3(col);

    if(!hit) imageStore(outputTexture, pixelCoords, vec4(0));
    //imageStore(outputTexture, pixelCoords, vec4(zBuffer,0.8));
    

}
