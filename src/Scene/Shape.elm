module Scene.Shape exposing
    ( Shape
    , dimensions
    , image
    , rectangle
    , textured
    , triangle
    , triangles
    )

import Color exposing (Color)
import Internal.Shape
import Internal.Vertex as Vertex exposing (Vertex)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Scene.Dimensions as Dimensions exposing (Dimensions)
import Scene.Point as Point exposing (Point)
import Scene.Texture exposing (Texture)


type Shape msg
    = Polygon
        { sides : Int
        , position : Point
        }
    | Colored (Shape msg) Color
    | Textured (Shape msg) Texture


dimensions : Shape msg -> Dimensions
dimensions =
    Debug.todo ""


tupleMapThree : (a -> b) -> ( a, a, a ) -> ( b, b, b )
tupleMapThree f ( x, y, z ) =
    ( f x, f y, f z )


triangles : List ( Point, Point, Point ) -> Shape msg
triangles positions =
    positions
        |> List.map (tupleMapThree Vertex.fromPoint)
        |> Internal.Shape.Triangles


triangle : Point -> Point -> Point -> Shape msg
triangle a b c =
    triangles [ ( a, b, c ) ]


rectangle : Dimensions -> Point -> Shape msg
rectangle size position =
    let
        x1 =
            Point.first position

        x2 =
            x1 + Dimensions.width size

        y1 =
            Point.second position

        y2 =
            y1 + Dimensions.height size
    in
    triangles
        [ ( Point.fromXY x1 y1
          , Point.fromXY x2 y1
          , Point.fromXY x1 y2
          )
        , ( Point.fromXY x1 y2
          , Point.fromXY x2 y1
          , Point.fromXY x2 y2
          )
        ]


image : Texture -> Point -> Shape msg
image texture position =
    Debug.todo "`image` not yet implemented."


textured : Texture -> Shape msg -> Shape msg
textured =
    Debug.todo "Textures not implemented yet"
