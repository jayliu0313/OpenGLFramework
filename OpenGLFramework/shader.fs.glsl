#version 330

in vec2 texCoord;
in vec3 vertex_color;
in vec3 vertex_normal;
in vec3 FragPos; 

out vec4 fragColor;

// [TODO] passing texture from main.cpp
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
vec3 result;

float attenuation = 1.0;
float spot_effect = 1.0;

// Hint: sampler2D
uniform sampler2D texture1;


void main() {
	
	if (isPerPixel == 1)
	{
		float dist;
		switch(lighting_mode)
		{
			// Directional_Ligting
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
		vec3 norm =  normalize(vertex_normal);

		// Ambient
		vec3 ambient = ambientIntensity * material.Ka;

		// Diffuse
		float diff = max(dot(norm, lightDir), 0.0);
		vec3 diffuse = diffuseIntensity * diff * material.Kd;
		
		//Specular
		vec3 viewDir = normalize(viewPos - FragPos);
		float spec = pow(max(dot(norm, normalize(lightDir + viewDir)), 0.0), shininess);
		vec3 specular = specularIntensity * spec * material.Ks;
		
		result = ambient + attenuation * spot_effect * (diffuse + specular);
	} 
	else
	{
		result = vertex_color;
	}
	// [TODO] sampleing from texture
	// Hint: texture
	fragColor = texture(texture1, texCoord) * vec4(result, 1.0);

}
