module Decoders exposing (decodeIncident)

import Json.Decode exposing (Decoder, float, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Models exposing (Address, Description, Incident)


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
