module Maze exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Dict
import Json.Decode exposing (decodeString, keyValuePairs, string)
import Maybe
import Result

main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- Model

type alias Maze =
  { description : Description
  , startPoint : Point
  , endPoint : Point
  }

type alias Description =
  List (Point, Directions)

type alias Point =
  { x : Int
  , y : Int
  }

type alias Directions =
  List Direction

type Direction = N | E | S | W | NoDir

type alias Model =
  { currentMaze : Maze
  , newMaze : Maze
  }

init : (Model, Cmd Msg)
init =
  let
    start = Point 0 0
    end = Point 0 0
  in
    (Model (Maze [] start end) (Maze [] start end) , Cmd.none)

-- Update

type Msg
  = Description String
  | UpdateCurrentMaze

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Description json ->
      let
        newMaze = model.newMaze
        newDescription = Result.withDefault newMaze.description (decodeDescription json)
        updatedNewMaze = { newMaze | description = newDescription }
      in
        ( { model | newMaze  = updatedNewMaze }
        , Cmd.none
        )

    UpdateCurrentMaze ->
      ( { model | currentMaze = model.newMaze }
      , Cmd.none
      )

decodeDescription : String -> Result String Description
decodeDescription json =
  let
    decoded = Result.withDefault [] (decodeString (keyValuePairs (Json.Decode.list string)) json)
    blocks = List.map convertBlock decoded

    convertBlock : (String, List String) -> (Point, Directions)
    convertBlock (point, directions) =
      (stringToPoint point, List.map stringToDirection directions)

    stringToPoint : String -> Point
    stringToPoint p =
      let
        integers = List.map String.toInt (String.split "," p)
        coordinates = List.map (Result.withDefault 0) integers
        x = Maybe.withDefault 0 (List.head coordinates)
        y = Maybe.withDefault 0 (List.head (Maybe.withDefault [] (List.tail coordinates)))
      in
        Point x y

    stringToDirection : String -> Direction
    stringToDirection d =
      case d of
        "N" -> N
        "E" -> E
        "S" -> S
        "W" -> W
        _ -> NoDir
  in
    if List.isEmpty blocks then
      Err "A valid maze has at least 1 block"
    else
      Ok blocks

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- View

view : Model -> Html Msg
view model =
  body [] 
    [ Html.form [ onSubmit UpdateCurrentMaze, action "#" ]
      [ input [ type_ "text", placeholder "Enter maze JSON description", onInput Description ] []
      , input [ type_ "submit", value "Update Maze" ] []
      ]
    , viewMaze model
    ]

viewMaze : Model -> Html Msg
viewMaze model =
  let
    style =
      [ ( ".maze"
        , [ ("position", "relative")
          , ("margin-top", "50px")
          , ("margin-left", "50px")
          ]
        )
      , ( ".maze--block"
        , [ ("position", "absolute")
          , ("box-sizing", "border-box")
          , ("background", "grey")
          , ("width", "50px")
          , ("height", "50px")
          ]
        )
      ]
  in
    div [ class "maze" ] 
      ( (scopedStyle style) 
      :: (List.map viewBlock model.currentMaze.description)
      )

viewBlock : (Point, Directions) -> Html msg
viewBlock (point, directions) =
  let
    style =
      [ ( ".maze--block"
        , [ ("left", (toString (50 * point.y)) ++ "px")
          , ("top", (toString (50 * point.x)) ++ "px")
          , ("border-top",    if List.member N directions then "none" else "2px solid blue")
          , ("border-right",  if List.member E directions then "none" else "2px solid blue")
          , ("border-bottom", if List.member S directions then "none" else "2px solid blue")
          , ("border-left",   if List.member W directions then "none" else "2px solid blue")
          ]
        )
      ]
  in
    div [ class "maze--block" ] [ scopedStyle style ]

scopedStyle : List (String, List (String, String)) -> Html msg
scopedStyle styles =
  node "style" [ attribute "scoped" "" ] (List.map selectorStyleToCss styles)

selectorStyleToCss : (String, List (String, String)) -> Html msg
selectorStyleToCss (selector, properties) =
  let
    propertiesAsCss = String.join " " (List.map (\(p, v) -> p ++ ": " ++ v ++ ";") properties)
  in
    text (selector ++ " { " ++ propertiesAsCss ++ " }")
