module Api exposing (parcel, weather)

import Decoders exposing (..)
import Http
import Json.Encode as Encode
import Models exposing (..)
import Time exposing (posixToMillis)
import Url.Builder exposing (crossOrigin, int, string)


weather : Incident -> (Result Http.Error Weather -> msg) -> Cmd msg
weather incident msg =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "X-RapidAPI-Host" "dark-sky.p.rapidapi.com"
            , Http.header "X-RapidAPI-Key" "ef837d0fb7msh45c8b0a4d9a184ep118d80jsn0d5d7d6c4516"
            ]
        , url =
            crossOrigin "https://dark-sky.p.rapidapi.com/"
                [ String.join ","
                    [ String.fromFloat incident.address.latitude
                    , String.fromFloat incident.address.longitude
                    , String.fromInt (posixToMillis incident.description.date // 1000)
                    ]
                ]
                []
        , body = Http.emptyBody
        , expect = Http.expectJson msg decodeWeather
        , timeout = Nothing
        , tracker = Nothing
        }


encodeGeometry : Float -> Float -> String
encodeGeometry lat lng =
    let
        wkid =
            Encode.object [ ( "wkid", Encode.int 4326 ) ]
    in
    Encode.object
        [ ( "spatialReference", wkid )
        , ( "x", Encode.float lng )
        , ( "y", Encode.float lat )
        ]
        |> Encode.encode 0


parcel : Incident -> (Result Http.Error (List Parcel) -> msg) -> Cmd msg
parcel incident msg =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Content-Type" "application/x-www-form-urlencoded", Http.header "Accept" "application/json" ]
        , url =
            crossOrigin
                "http://gis.richmondgov.com/ArcGIS/rest/services/StatePlane4502/Ener/MapServer/0/query"
                []
                [ string "f" "pjson"
                , string "geometryType" "esriGeometryPoint"
                , string "geometry" (encodeGeometry incident.address.latitude incident.address.longitude)
                , string "outFields" "OwnerName,MailAddress,LandValue,LandSqFt"
                , int "time" <| posixToMillis incident.description.date
                , string "returnCountOnly" "false"
                , string "returnIdsOnly" "false"
                , string "returnGeometry" "false"
                , string "spatialRel" "esriSpatialRelWithin"
                ]
        , body = Http.emptyBody
        , expect = Http.expectJson msg decodeParcel
        , timeout = Nothing
        , tracker = Nothing
        }
