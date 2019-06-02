port module Ports exposing (mapReady, resetMap, showIncident, syncMap, updateViewport)

import Json.Decode as Decode
import Models exposing (Pin, Viewport)


port updateViewport : (Decode.Value -> msg) -> Sub msg


port showIncident : (Decode.Value -> msg) -> Sub msg


port mapReady : (Decode.Value -> msg) -> Sub msg


port resetMap : {} -> Cmd msg


port syncMap :
    { viewport : Viewport
    , id : String
    , pins : List Pin
    }
    -> Cmd msg
