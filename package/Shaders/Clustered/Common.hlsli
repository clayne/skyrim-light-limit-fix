
#define GROUP_SIZE (16*16*4)
#define MAX_CLUSTER_LIGHTS 128
#define CLUSTER_CULLING_DISPATCH_SIZE_X 1
#define CLUSTER_CULLING_DISPATCH_SIZE_Y 1
#define CLUSTER_CULLING_DISPATCH_SIZE_Z 4

#define CLUSTER_BUILDING_DISPATCH_SIZE_X 16
#define CLUSTER_BUILDING_DISPATCH_SIZE_Y 16
#define CLUSTER_BUILDING_DISPATCH_SIZE_Z 16

struct ClusterAABB
{
    float4 min_point;
    float4 max_point;
};

struct LightGrid
{
    uint offset;
    uint light_count;
};

struct StructuredLight
{
    float4 position;
    float4 direction;
    float4 color;
    int active;
    float range;
    int type;
    float outer_cosine;
    float inner_cosine;
    int casts_shadows;
    int use_cascades;
    int padd;
};

cbuffer PerFrame : register(b0)
{
    float4 global_ambient;
    
    row_major matrix view;
    
    row_major matrix projection;
    
    row_major matrix viewprojection;
    
    row_major matrix inverse_view;
    
    row_major matrix inverse_projection;
    
    row_major matrix inverse_view_projection;
    
    row_major matrix prev_view;
    
    row_major matrix prev_projection;
    
    row_major matrix prev_view_projection;
    
    float4 camera_position;
    
    float4 camera_forward;
    
    float camera_near;
    
    float camera_far;
    
    float2 screen_resolution;

    float2 mouse_normalized_coords;
}


cbuffer ComputeCBuffer : register(b6)
{
    float bloom_scale;  //bloom
    float threshold;    //bloom
    
    float gauss_coeff1; //blur coefficients
    float gauss_coeff2; //blur coefficients
    float gauss_coeff3; //blur coefficients
    float gauss_coeff4; //blur coefficients
    float gauss_coeff5; //blur coefficients
    float gauss_coeff6; //blur coefficients
    float gauss_coeff7; //blur coefficients
    float gauss_coeff8; //blur coefficients
    float gauss_coeff9; //blur coefficients
    
    float bokeh_fallout;        //bokeh
    float4 dof_params;          //bokeh
    float bokeh_radius_scale;   //bokeh
    float bokeh_color_scale;    //bokeh
    float bokeh_blur_threshold; //bokeh
    float bokeh_lum_threshold;  //bokeh	
    
    int ocean_size;             //ocean
    int resolution;             //ocean
    float ocean_choppiness;     //ocean								
    float wind_direction_x;     //ocean and particles
    float wind_direction_y;     //ocean and particles
    float delta_time;           //ocean and particles
    int visualize_tiled;        //tiled rendering
    int lights_count_white;
}

float ConvertZToLinearDepth(float depth)
{
    float near = camera_near;
    float far = camera_far;
    
    return (near * far) / (far - depth * (far - near));
}

float3 GetPositionVS(float2 texcoord, float depth)
{
    float4 clipSpaceLocation;
    clipSpaceLocation.xy = texcoord * 2.0f - 1.0f;
    clipSpaceLocation.y *= -1;
    clipSpaceLocation.z = depth;
    clipSpaceLocation.w = 1.0f;
    float4 homogenousLocation = mul(clipSpaceLocation, inverse_projection);
    return homogenousLocation.xyz / homogenousLocation.w;
}

#define DIRECTIONAL_LIGHT 0
#define POINT_LIGHT 1
#define SPOT_LIGHT 2
