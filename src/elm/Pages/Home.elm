module Pages.Home exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, a, div, p, text)
import Html.Attributes exposing (class, href, id)
import Models exposing (Incident, Pin, Point, Viewport)
import Ports
import Routing
import Util exposing (incidentCategory, incidentTitle)


type Msg
    = UpdateViewport Viewport


type alias Model =
    { incidents : List Incident
    , viewport : Viewport
    }


mapId : String
mapId =
    "the_map"


syncMap : Model -> Cmd msg
syncMap { incidents, viewport } =
    Ports.syncMap
        { viewport = viewport
        , id = mapId
        , pins = List.map (\incident -> Pin (Point incident.address.latitude incident.address.longitude) incident.description.incident_number) incidents
        }


init : List Incident -> ( Model, Cmd Msg )
init incidents =
    let
        center =
            case List.head incidents of
                Just incident ->
                    Point incident.address.latitude incident.address.longitude

                Nothing ->
                    Point 0 0

        model =
            { incidents = incidents
            , viewport = Viewport center 8
            }
    in
    ( model, syncMap model )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateViewport vp ->
            ( { model | viewport = vp }, Cmd.none )


viewIncident : Incident -> Html msg
viewIncident incident =
    a [ href <| Routing.toString <| Routing.IncidentRoute incident.description.incident_number ]
        [ div [ class "item" ]
            [ p [ class "title" ] [ text incident.address.common_place_name ]
            , p [ class "address" ] [ text <| incidentTitle incident ]
            , p [ class "cat" ] [ text <| incidentCategory incident ]
            ]
        ]


view : Model -> Html msg
view { incidents } =
    div [ class "section home" ]
        [ div [ class "details incident_list" ] (List.map viewIncident incidents)
        , div [ class "map", id mapId ] []
        ]
