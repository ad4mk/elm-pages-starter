port module Route.About exposing (Model, Msg, RouteParams, route, Data, ActionData)

{-|

@docs Model, Msg, RouteParams, route, Data, ActionData

-}

import BackendTask
import Effect
import ErrorPage
import FatalError
import Head
import Head.Seo as Seo
import Html
import Html.Events exposing (onClick)
import Pages.Url
import PagesMsg
import RouteBuilder
import Server.Request
import Server.Response
import Shared
import Task
import UrlPath
import View


type alias Model =
    { displayString : Int
    }


type Msg
    = NoOp
    | TestFirst
    | TestSecond
    | SendMessage String


type alias RouteParams =
    {}


port sendMessageToJs : String -> Cmd msg


route : RouteBuilder.StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.serverRender { data = data, action = action, head = head }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> ( Model, Effect.Effect Msg )
init app shared =
    ( { displayString = 0 }
    , Effect.Cmd (Task.perform (always (SendMessage "About paged loaded from About.elm")) (Task.succeed ()))
    )


update :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Msg
    -> Model
    -> ( Model, Effect.Effect Msg )
update app shared msg model =
    case msg of
        NoOp ->
            ( model, Effect.None )

        TestFirst ->
            ( { model | displayString = model.displayString + 1 }
            , Effect.Cmd (Task.perform (always TestSecond) (Task.succeed ()))
            )

        TestSecond ->
            ( { model | displayString = model.displayString + 1 }, Effect.none )

        SendMessage message ->
            ( model, Effect.Cmd (sendMessageToJs message) )


subscriptions : RouteParams -> UrlPath.UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


type alias Data =
    { test : String }


type alias ActionData =
    {}


data :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response Data ErrorPage.ErrorPage)
data routeParams request =
    BackendTask.succeed (Server.Response.render { test = "" })


head : RouteBuilder.App Data ActionData RouteParams -> List Head.Tag
head app =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-pages"
        , image =
            { url = Pages.Url.external "TODO"
            , alt = "elm-pages logo"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "About us"
        , locale = Nothing
        , title = "About Us" -- metadata.title -- TODO
        }
        |> Seo.website


view :
    RouteBuilder.App Data ActionData RouteParams
    -> Shared.Model
    -> Model
    -> View.View (PagesMsg.PagesMsg Msg)
view app shared model =
    { title = "About"
    , body =
        [ Html.h2 []
            [ Html.text "New Page Testing" ]
        , Html.button [ onClick (PagesMsg.fromMsg TestFirst) ]
            [ Html.text ("Click Me: " ++ String.fromInt model.displayString) ]
        ]
    }


action :
    RouteParams
    -> Server.Request.Request
    -> BackendTask.BackendTask FatalError.FatalError (Server.Response.Response ActionData ErrorPage.ErrorPage)
action routeParams request =
    BackendTask.succeed (Server.Response.render {})
