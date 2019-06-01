module Main exposing (main)

import Browser exposing (Document, UrlRequest(..), application)
import Browser.Navigation as Navigation
import Decoders exposing (decodeIncident)
import Html exposing (Html, a, button, div, h1, pre, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Models exposing (Incident)
import Pages.Home as HomePage
import Pages.Incident as IncidentPage
import Routing
import Url exposing (Url)


type PageData
    = HomeData HomePage.Model
    | IncidentData IncidentPage.Model
    | InvalidFlagsData Decode.Error
    | NotFoundData String


type alias Model =
    { page : PageData
    , nav_key : Navigation.Key
    , incidents : List Incident
    }


type Msg
    = UrlChanged Url
    | UrlRequested UrlRequest
    | IncidentMessage IncidentPage.Msg


isEqual : String -> Incident -> Bool
isEqual id incident =
    incident.description.incident_number == id


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            case Routing.fromUrl url of
                Routing.HomeRoute ->
                    ( { model | page = HomeData model.incidents }, Cmd.none )

                Routing.IncidentRoute id ->
                    case List.filter (isEqual id) model.incidents |> List.head of
                        Just incident ->
                            ( { model | page = IncidentData { incident = incident } }, Cmd.none )

                        Nothing ->
                            ( { model | page = NotFoundData "Incident Not Found" }, Cmd.none )

                _ ->
                    ( { model | page = NotFoundData "Invalid Url" }, Cmd.none )

        UrlRequested url_request ->
            case url_request of
                Internal url ->
                    ( model, Navigation.pushUrl model.nav_key <| Url.toString url )

                External href ->
                    ( model, Navigation.load href )

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


viewHeader : Html msg
viewHeader =
    div
        [ class "header" ]
        [ div [ class "title" ]
            [ a [ href "/" ] [ text "Incident Explorer" ] ]
        ]


viewBody : PageData -> Html Msg
viewBody page =
    case page of
        HomeData mod ->
            HomePage.view mod

        IncidentData mod ->
            Html.map IncidentMessage <| IncidentPage.view mod

        InvalidFlagsData err ->
            div []
                [ h1 [] [ text "Error" ]
                , pre [] [ text <| Decode.errorToString err ]
                ]

        NotFoundData reason ->
            div [] [ text reason ]


view : Model -> Document Msg
view { page } =
    { title =
        case page of
            HomeData _ ->
                "Incident Explorer"

            IncidentData { incident } ->
                "Incident View - " ++ incident.address.address_line1

            InvalidFlagsData err ->
                "Error - " ++ Decode.errorToString err

            NotFoundData reason ->
                "Not Found - " ++ reason
    , body =
        [ div [ id "root" ]
            [ viewHeader
            , div [ class "main" ] [ viewBody page ]
            ]
        ]
    }


init : Decode.Value -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags url nav_key =
    case Decode.decodeValue (Decode.list decodeIncident) flags of
        Ok incidents ->
            ( { nav_key = nav_key
              , page = HomeData incidents
              , incidents = incidents
              }
            , Cmd.none
            )

        Err e ->
            ( { nav_key = nav_key
              , page = InvalidFlagsData e
              , incidents = []
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
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
