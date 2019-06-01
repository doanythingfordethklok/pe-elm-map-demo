module Routing exposing (Route(..), fromUrl, toString)

import Parser
import Url exposing (Url)
import Url.Builder as UrlBuilder exposing (absolute)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = HomeRoute
    | IncidentRoute String
    | NotFoundRoute


parser : Parser (Route -> a) a
parser =
    oneOf
        [ map HomeRoute top
        , map IncidentRoute (s "incident" </> string)
        ]


fromUrl : Url -> Route
fromUrl url =
    case parse parser url of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


toString : Route -> String
toString route =
    case route of
        HomeRoute ->
            absolute [] []

        IncidentRoute incident_id ->
            absolute [ "incident", incident_id ] []

        NotFoundRoute ->
            absolute [ "not-found" ] []
