module Pages.Incident exposing (Model, Msg, update, view)

import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes exposing (class, href)
import Models exposing (Incident)


type Msg
    = Noop


type alias Model =
    { incident : Incident
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] [ text "Incident" ]
