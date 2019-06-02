module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as Navigation
import Decoders exposing (decodeIncident, decodeViewport)
import Html exposing (Html, a, button, div, h1, i, pre, span, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Models exposing (..)
import Pages.Home as HomePage
import Pages.Incident as IncidentPage
import Ports
import Routing
import Url exposing (Url)


type PageData
    = HomeData HomePage.Model
    | IncidentData IncidentPage.Model
    | InvalidFlagsData Decode.Error
    | NotFoundData String


type alias Model =
    { url : Url
    , page : PageData
    , nav_key : Navigation.Key
    , incidents : List Incident
    }


type Msg
    = MapsLoaded
    | NavigateTo String
    | Noop
    | UrlChanged Url
    | UrlRequested UrlRequest
    | HomeMessage HomePage.Msg
    | IncidentMessage IncidentPage.Msg


isEqual : String -> Incident -> Bool
isEqual id incident =
    incident.description.incident_number == id


locationChanged : Model -> ( Model, Cmd Msg )
locationChanged model =
    case Routing.fromUrl model.url of
        Routing.HomeRoute ->
            let
                ( data, cmd ) =
                    HomePage.init model.incidents
            in
            ( { model | page = HomeData data }, Cmd.batch [ Ports.resetMap {}, Cmd.map HomeMessage cmd ] )

        Routing.IncidentRoute id ->
            case List.filter (isEqual id) model.incidents |> List.head of
                Just incident ->
                    let
                        ( data, cmd ) =
                            IncidentPage.init incident
                    in
                    ( { model | page = IncidentData data }, Cmd.batch [ Ports.resetMap {}, Cmd.map IncidentMessage cmd ] )

                Nothing ->
                    ( { model | page = NotFoundData "Incident Not Found" }, Cmd.none )

        _ ->
            ( { model | page = NotFoundData "Invalid Url" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            locationChanged { model | url = url }

        UrlRequested url_request ->
            case url_request of
                Internal url ->
                    ( model, Navigation.pushUrl model.nav_key <| Url.toString url )

                External href ->
                    ( model, Navigation.load href )

        NavigateTo url ->
            ( model, Navigation.pushUrl model.nav_key url )

        MapsLoaded ->
            locationChanged model

        Noop ->
            ( model, Cmd.none )

        IncidentMessage submsg ->
            case model.page of
                IncidentData data ->
                    let
                        ( page, cmd ) =
                            IncidentPage.update submsg data
                    in
                    ( { model | page = IncidentData page }, Cmd.map IncidentMessage cmd )

                _ ->
                    ( model, Cmd.none )

        HomeMessage submsg ->
            case model.page of
                HomeData data ->
                    let
                        ( page, cmd ) =
                            HomePage.update submsg data
                    in
                    ( { model | page = HomeData page }, Cmd.map HomeMessage cmd )

                _ ->
                    ( model, Cmd.none )


viewHeader : Maybe Incident -> Html msg
viewHeader incident =
    div [ class "header" ]
        [ div [ class "title" ]
            (case incident of
                Just { address } ->
                    [ a [ href "/" ] [ i [ class "material-icons" ] [ text "arrow_back" ] ], span [] [ text address.common_place_name ] ]

                Nothing ->
                    [ text "Incident Explorer" ]
            )
        ]


view : Model -> Document Msg
view { page } =
    { title =
        case page of
            HomeData _ ->
                "Incident Explorer"

            IncidentData { incident } ->
                incident.address.address_line1

            InvalidFlagsData err ->
                "Error - " ++ Decode.errorToString err

            NotFoundData reason ->
                "Not Found - " ++ reason
    , body =
        [ div [ id "root" ]
            (case page of
                HomeData mod ->
                    [ viewHeader Nothing
                    , div [ class "main" ] [ HomePage.view mod ]
                    ]

                IncidentData mod ->
                    [ viewHeader <| Just mod.incident
                    , div [ class "main" ] [ Html.map IncidentMessage <| IncidentPage.view mod ]
                    ]

                InvalidFlagsData err ->
                    [ viewHeader Nothing
                    , div [ class "main" ]
                        [ div []
                            [ h1 [] [ text "Error" ]
                            , pre [] [ text <| Decode.errorToString err ]
                            ]
                        ]
                    ]

                NotFoundData reason ->
                    [ viewHeader Nothing
                    , div [ class "main" ] [ text reason ]
                    ]
            )
        ]
    }


init : Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url nav_key =
    case Decode.decodeValue (Decode.list decodeIncident) flags of
        Ok incidents ->
            ( { url = url
              , nav_key = nav_key
              , page = NotFoundData "Loading Google Maps"
              , incidents = incidents
              }
            , Cmd.none
            )

        Err e ->
            ( { url = url
              , nav_key = nav_key
              , page = InvalidFlagsData e
              , incidents = []
              }
            , Cmd.none
            )


decodeIncidentClick : Decode.Value -> Msg
decodeIncidentClick val =
    Result.map (NavigateTo << Routing.toString << Routing.IncidentRoute) (Decode.decodeValue Decode.string val)
        |> Result.withDefault Noop


decodeViewportUpdate : (Viewport -> Msg) -> Decode.Value -> Msg
decodeViewportUpdate msg val =
    Result.map msg (Decode.decodeValue decodeViewport val)
        |> Result.withDefault Noop


subscriptions : Model -> Sub Msg
subscriptions { page } =
    case page of
        HomeData _ ->
            Sub.batch
                [ Ports.showIncident decodeIncidentClick
                , Ports.updateViewport (decodeViewportUpdate (HomeMessage << HomePage.UpdateViewport))
                ]

        IncidentData _ ->
            Ports.updateViewport (decodeViewportUpdate (IncidentMessage << IncidentPage.UpdateViewport))

        NotFoundData _ ->
            Ports.mapReady (always MapsLoaded)

        _ ->
            Sub.none


main : Program Decode.Value Model Msg
main =
    application
        { init = init
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
