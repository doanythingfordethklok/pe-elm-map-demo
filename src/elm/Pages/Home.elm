module Pages.Home exposing (Model, view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Models exposing (Incident)
import Routing


type alias Model =
    List Incident


incidentTitle : Incident -> String
incidentTitle incident =
    String.join ", " [ incident.address.address_line1, incident.address.city, incident.address.state ]


incidentCategory : Incident -> String
incidentCategory incident =
    String.join " • " [ incident.description.cat, incident.description.sub_cat ]


viewIncident : Incident -> Html msg
viewIncident incident =
    div [ class "card" ]
        [ p [ class "title" ] [ text incident.address.common_place_name ]
        , p [ class "address" ] [ text <| incidentTitle incident ]
        , p [ class "cat" ] [ text <| incidentCategory incident ]
        , div [ class "actions" ]
            [ a [ href <| Routing.toString <| Routing.IncidentRoute incident.description.incident_number ] [ text "View Incident" ]
            ]
        ]


view : Model -> Html msg
view incidents =
    div [ class "section home" ] (List.map viewIncident incidents)
