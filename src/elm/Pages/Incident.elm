module Pages.Incident exposing (Model, Msg(..), init, update, view)

import Api
import Html exposing (Html, div, p, strong, text)
import Html.Attributes exposing (class, id)
import Http
import Models exposing (Incident, Parcel, Pin, Point, Viewport, Weather)
import Ports
import Snackbar exposing (Snackbar)
import Task
import Time exposing (Zone)
import Util exposing (errorToString, formatDate, incidentCategory, incidentTitle)


type Msg
    = UpdateViewport Viewport
    | UpdateWeather (Result Http.Error Weather)
    | UpdateParcel (Result Http.Error (List Parcel))
    | SnackMessage (Snackbar.Msg Msg)
    | SetZone Zone


type alias Model =
    { incident : Incident
    , viewport : Viewport
    , weather : Maybe Weather
    , parcel : Maybe Parcel
    , snackbar : Snackbar Msg
    , timezone : Zone
    }


syncMap : Model -> Cmd msg
syncMap { incident, viewport } =
    Ports.syncMap
        { viewport = viewport
        , id = mapId
        , pins = [ Pin (Point incident.address.latitude incident.address.longitude) incident.description.incident_number ]
        }


mapId : String
mapId =
    "the_map"


init : Incident -> ( Model, Cmd Msg )
init incident =
    let
        model =
            { incident = incident
            , weather = Nothing
            , parcel = Nothing
            , snackbar = Snackbar.hidden
            , timezone = Time.utc
            , viewport = Viewport (Point incident.address.latitude incident.address.longitude) 13
            }
    in
    ( model
    , Cmd.batch
        [ syncMap model
        , Api.weather incident UpdateWeather
        , Api.parcel incident UpdateParcel
        , Task.perform SetZone Time.here
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateViewport vp ->
            ( { model | viewport = vp }, Cmd.none )

        UpdateWeather result ->
            case result of
                Ok w ->
                    ( { model | weather = Just w }, Cmd.none )

                Err e ->
                    let
                        ( sb, cmd ) =
                            Snackbar.message Snackbar.DefaultDelay (errorToString e)
                    in
                    ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )

        UpdateParcel result ->
            case result of
                Ok parcels ->
                    ( { model | parcel = List.head parcels }, Cmd.none )

                Err e ->
                    let
                        ( sb, cmd ) =
                            Snackbar.message Snackbar.DefaultDelay (errorToString e)
                    in
                    ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )

        SnackMessage submsg ->
            let
                ( sb, cmd ) =
                    Snackbar.update submsg model.snackbar
            in
            ( { model | snackbar = sb }, Cmd.map SnackMessage cmd )

        SetZone z ->
            ( { model | timezone = z }, Cmd.none )


viewWeather : Weather -> Html msg
viewWeather weather =
    div []
        [ div [ class "sep" ] []
        , strong [] [ text "WEATHER STUFF" ]
        , p [ class "cat" ]
            [ text <| weather.summary ++ " "
            , text <| String.fromInt <| round weather.temperature
            , text "º F"
            ]
        ]


viewParcel : Parcel -> Html msg
viewParcel parcel =
    div []
        [ div [ class "sep" ] []
        , strong [] [ text "PARCEL STUFF" ]
        , p [ class "cat" ] [ text <| "Land Owner: " ++ parcel.owner ]
        , p [ class "cat" ] [ text <| "Land Value: " ++ String.fromFloat parcel.land_value ]
        , p [ class "cat" ] [ text <| "Land Sqft: " ++ String.fromFloat parcel.land_sqft ]
        ]


view : Model -> Html Msg
view { incident, timezone, weather, parcel, snackbar } =
    div [ class "section incident" ]
        [ div [ class "details" ]
            [ div [ class "item" ]
                [ p [ class "title" ] [ text incident.address.common_place_name ]
                , p [ class "address" ] [ text <| incidentTitle incident ]
                , p [ class "cat" ] [ text <| formatDate timezone incident.description.date ]
                , Maybe.map viewWeather weather |> Maybe.withDefault (text "")
                , Maybe.map viewParcel parcel |> Maybe.withDefault (text "")
                , div [ class "sep" ] []
                , strong [] [ text <| incidentCategory incident ]
                , p [ class "cat" ] [ text <| String.left 400 incident.description.comments, text "..." ]
                ]
            ]
        , div [ class "map", id mapId ] []
        , Snackbar.view snackbar
        ]
