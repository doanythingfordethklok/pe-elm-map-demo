module Decoders exposing (decodeIncident, decodeParcel, decodeViewport, decodeWeather)

import Iso8601
import Json.Decode exposing (Decoder, at, float, int, list, map2, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Models exposing (Address, Description, Incident, Parcel, Point, Viewport, Weather)


decodeIncident : Decoder Incident
decodeIncident =
    succeed Incident
        |> required "address" decodeAddress
        |> required "description" decodeDescription


decodeAddress : Decoder Address
decodeAddress =
    succeed Address
        |> required "address_line1" string
        |> required "city" string
        |> required "state" string
        |> required "common_place_name" string
        |> required "latitude" float
        |> required "longitude" float


decodeDescription : Decoder Description
decodeDescription =
    succeed Description
        |> required "incident_number" string
        |> required "type" string
        |> required "subtype" string
        |> required "event_opened" Iso8601.decoder
        |> required "comments" string


decodePoint : Decoder Point
decodePoint =
    succeed Point
        |> required "lat" float
        |> required "lng" float


decodeViewport : Decoder Viewport
decodeViewport =
    succeed Viewport
        |> required "center" decodePoint
        |> required "zoom" int


decodeWeather : Decoder Weather
decodeWeather =
    map2 Weather
        (at [ "currently", "temperature" ] float)
        (at [ "currently", "summary" ] string)


decodeAttributes : Decoder Parcel
decodeAttributes =
    at [ "attributes" ]
        (succeed Parcel
            |> required "OwnerName" string
            |> required "MailAddress" string
            |> required "LandValue" float
            |> required "LandSqFt" float
        )


decodeParcel : Decoder (List Parcel)
decodeParcel =
    at [ "features" ] (list decodeAttributes)
