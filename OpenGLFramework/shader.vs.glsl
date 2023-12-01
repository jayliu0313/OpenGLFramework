#version 330

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec3 aNormal;
layout (location = 3) in vec2 aTexCoord;

out vec2 texCoord;
out vec3 vertex_color;
out vec3 vertex_normal;
out vec3 FragPos;

uniform mat4 um4p;	
uniform mat4 um4v;
uniform mat4 um4m;
uniform mat4 normal_transform;

struct Material
{
    vec3 Ka;
    vec3 Kd;
    vec3 Ks;
};
uniform Material material;
uniform vec3 lightPos;
uniform vec3 viewPos;
uniform int isPerPixel;
uniform int lighting_mode;
uniform float shininess;
uniform float cutoff;
uniform vec3 diffuseIntensity;

vec3 ambientIntensity = vec3(0.15, 0.15, 0.15);
vec3 specularIntensity = vec3(1.0, 1.0, 1.0);

vec3 lightDir;
float attenuation = 1.0;
float spot_effect = 1.0;

uniform vec2 eyeOffset;

void main() 
{
	// [TODO]
	texCoord = aTexCoord + eyeOffset;
	
	gl_Position = um4p * um4v * um4m * vec4(aPos, 1.0);
	
	FragPos = vec3(um4m * vec4(aPos, 1.0));
	vertex_normal = vec3(normal_transform * vec4(aNormal, 0.0));
	
	if (isPerPixel == 0)
	{
		float dist;
		switch(lighting_mode)
		{
			case 0:
				lightDir = normalize(lightPos - vec3(0, 0, 0));
				break;

			case 1:
				lightDir = normalize(lightPos - FragPos);
				dist = length(lightPos - FragPos);
				attenuation = 1.0 / (0.01 + 0.8 * dist + 0.1 * dist * dist);
				break;

			case 2:
				lightDir = normalize(lightPos - FragPos);
				vec3 v = -lightDir;
				vec3 d = normalize(vec3(0, 0, -1));
				if (max(dot(v, d), 0.0) < cutoff)
					spot_effect = 0.0;
				else
					spot_effect = pow(max(dot(v, d), 0.0), 50);
				dist = length(lightPos - FragPos);
				attenuation = 1.0 / (0.05 + 0.3 * dist + 0.6 * dist * dist);
				break;			
		}

		vec3 norm = normalize(vertex_normal);

		vec3 ambient = ambientIntensity * material.Ka;

		float diff = max(dot(norm, lightDir), 0.0);
		vec3 diffuse = diffuseIntensity * diff * material.Kd;

		vec3 viewDir = normalize(viewPos - FragPos);
		float spec = pow(max(dot(norm, normalize(lightDir + viewDir)), 0.0), shininess);
		vec3 specular = specularIntensity * spec * material.Ks; 

		vertex_color = ambient + attenuation * spot_effect * (diffuse + specular);

	} else {
		vertex_color = aColor;
	}
	
}
