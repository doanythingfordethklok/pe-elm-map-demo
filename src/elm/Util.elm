module Util exposing (errorToString, formatDate, incidentCategory, incidentTitle)

import Http exposing (Error(..))
import Models exposing (..)
import Time exposing (Month(..), Posix, Zone, toDay, toHour, toMinute, toMonth, toYear)


incidentTitle : Incident -> String
incidentTitle incident =
    String.join ", " [ incident.address.address_line1, incident.address.city, incident.address.state ]


incidentCategory : Incident -> String
incidentCategory incident =
    String.join " • " [ incident.description.cat, incident.description.sub_cat ]


errorToString : Http.Error -> String
errorToString err =
    case err of
        Timeout ->
            "timeout"

        NetworkError ->
            "network problem"

        BadUrl _ ->
            "bad url"

        BadBody msg ->
            "Parsing error. " ++ msg

        BadStatus code ->
            "bad response code " ++ String.fromInt code


toMonthString : Month -> String
toMonthString month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"


dateString : Zone -> Posix -> String
dateString timezone dt =
    String.join
        ""
        [ toMonth timezone dt |> toMonthString
        , " "
        , toDay timezone dt |> String.fromInt
        , ", "
        , toYear timezone dt |> String.fromInt
        ]


timeString : Zone -> Posix -> String
timeString timezone dt =
    let
        meridiem : Int -> String
        meridiem h =
            if h < 12 then
                "AM"

            else
                "PM"

        meridiemHour : Int -> String
        meridiemHour h =
            if h == 0 then
                "12"

            else if h > 12 then
                h - 12 |> String.fromInt

            else
                String.fromInt h
    in
    String.join
        ""
        [ toHour timezone dt |> meridiemHour
        , ":"
        , toMinute timezone dt |> String.fromInt |> String.padLeft 2 '0'
        , " "
        , toHour timezone dt |> meridiem
        ]


formatDate : Zone -> Posix -> String
formatDate timezone dt =
    String.join " " [ dateString timezone dt, timeString timezone dt ]
