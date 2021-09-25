module Internal.Render exposing (makeViewProjection, shapeToEntity)

import Internal.Shape
import Internal.Texture
import Internal.Vertex as Vertex exposing (Vertex)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 exposing (vec3)
import Scene.Camera as Camera exposing (Camera)
import Scene.Dimensions as Dimensions exposing (Dimensions)
import Scene.Point as Point exposing (Point)
import Scene.Shape as Shape exposing (Shape)
import WebGL
import WebGL.Texture


makeProjection : Dimensions -> Mat4
makeProjection dimensions =
    Mat4.makeOrtho
        0
        (Dimensions.width dimensions)
        (Dimensions.height dimensions)
        0
        -1
        -1


makeViewProjection : Camera -> Mat4
makeViewProjection camera =
    let
        dimensions =
            Camera.dimensions camera
    in
    Mat4.inverseOrthonormal (makeCamera camera)
        |> Mat4.mul (makeProjection dimensions)


makeCamera : Camera -> Mat4
makeCamera camera =
    let
        position =
            Camera.position camera
    in
    Mat4.identity
        |> Mat4.translate
            (vec3
                (Point.first position)
                (Point.second position)
                0
            )


shapeToEntity : Mat4 -> Shape msg -> WebGL.Entity
shapeToEntity viewProjection shape =
    -- let
    --     mesh =
    --         Internal.Shape.toMesh shape
    -- in
    -- case Internal.Shape.toTexture shape of
    --     Just texture ->
    --         WebGL.entity
    --             texturedVertexShader
    --             texturedFragmentShader
    --             mesh
    --             { u_matrix = viewProjection
    --             , u_texture =
    --                 Internal.Texture.toWebGLTexture
    --                     texture
    --             }
    --     Nothing ->
    --         WebGL.entity vertexShader
    --             fragmentShader
    --             mesh
    --             { u_matrix = viewProjection }
    Debug.todo "Not yet implemented"


type alias Uniforms =
    { u_matrix : Mat4 }


type alias TexturedUniforms =
    { u_matrix : Mat4
    , u_texture : WebGL.Texture.Texture
    }


vertexShader : WebGL.Shader Vertex.Untextured Uniforms {}
vertexShader =
    [glsl|
        attribute vec2 a_position;
        uniform mat4 u_matrix;
        void main() {
          // Multiply the position by the matrix.
          gl_Position = vec4((u_matrix * vec4(a_position, 1, 1)).xy, 0, 1);
        } 
    |]


texturedVertexShader :
    WebGL.Shader
        Vertex.Textured
        TexturedUniforms
        { v_texcoord : Vec2 }
texturedVertexShader =
    [glsl|
        attribute vec2 a_position;
        attribute vec2 a_texcoord;
        
        uniform mat4 u_matrix;
        varying vec2 v_texcoord;
        void main() {
            // Multiply the position by the matrix.
            gl_Position = vec4((u_matrix * vec4(a_position, 1, 1)).xy, 0, 1);
            v_texcoord = a_texcoord;
        }
    |]


fragmentShader : WebGL.Shader {} Uniforms {}
fragmentShader =
    [glsl|
        precision mediump float;
        // uniform vec4 u_color;
        void main() {
            gl_FragColor = vec4(0, 0, 0, 1);
        }
    |]


texturedFragmentShader :
    WebGL.Shader
        {}
        TexturedUniforms
        { v_texcoord : Vec2 }
texturedFragmentShader =
    [glsl|
        precision mediump float;
 
        varying vec2 v_texcoord;
        
 
        uniform sampler2D u_texture;
         
        void main() {
           gl_FragColor = texture2D(u_texture, v_texcoord);
        }
    |]
