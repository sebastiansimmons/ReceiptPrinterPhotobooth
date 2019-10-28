// Shader that turns color image into grayscale
#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
varying vec4 vertTexCoord;

void main () {
  vec4 normalColor = texture2D(texture, vertTexCoord.xy);
  float gray = 0.299*normalColor.r + 0.587*normalColor.g + 0.114*normalColor.b;
  gl_FragColor = vec4(gray, gray, gray, normalColor.a);
}
