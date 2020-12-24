module Main exposing (..)

import Browser
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import LetterDayCalendar as LDC
import Task
import Time


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : a -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        ]
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- UPDATE


type Msg
    = AdjustTimeZone Time.Zone
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    H.div [ HA.class "pure-g container" ]
        [ H.div
            [ HA.class "pure-u-1 pure-u-md-1-2 max-width-450px justify-center"
            , HA.id "snowman-container"
            ]
            [ viewSnowman ]
        , H.div
            [ HA.class "pure-u-1 pure-u-md-1-2 max-width-450px justify-center"
            , HA.id "info-container"
            ]
            [ H.h1 [ HA.class "" ]
                [ H.text "Welcome to Penndale!" ]
            , viewTime model
            , viewLetterDay
                model
            ]
        ]


viewTime : Model -> Html Msg
viewTime model =
    H.div []
        [ H.p []
            [ H.text (dateAndTime model) ]
        ]


viewLetterDay : Model -> Html Msg
viewLetterDay model =
    let
        letterDay =
            LDC.letterDayFromTime model.zone model.time

        imgInfo =
            LDC.letterDayImgInfo letterDay
    in
    H.div []
        [ H.p []
            [ H.img
                [ HA.src imgInfo.src
                , HA.height 200
                , HA.alt imgInfo.alt
                ]
                []
            ]
        ]


viewSnowman : Html Msg
viewSnowman =
    H.div []
        [ H.img
            [ HA.src "./../assets/images/snowman.svg"
            , HA.height 450
            , HA.alt "Snowman"
            ]
            []
        ]



-- UTILS


parseHour : Time.Zone -> Time.Posix -> { hour : Int, period : Period }
parseHour zone posix =
    let
        hour =
            Time.toHour zone posix

        thing =
            modBy 12 hour
    in
    if hour <= 0 then
        -- Less than zero shouldn't happen, just make it 12AM if it does
        { hour = 12
        , period = AM
        }

    else if hour < 12 then
        { hour = hour, period = AM }

    else if hour == 12 then
        { hour = 12, period = PM }

    else if hour < 24 then
        { hour = modBy 12 hour, period = PM }

    else
        -- Again, shouldn't happen, but if it does, just set to 12AM
        { hour = 12, period = AM }


toWeekdayString : Time.Weekday -> String
toWeekdayString weekday =
    case weekday of
        Time.Mon ->
            "Mon"

        Time.Tue ->
            "Tue"

        Time.Wed ->
            "Wed"

        Time.Thu ->
            "Thu"

        Time.Fri ->
            "Fri"

        Time.Sat ->
            "Sat"

        Time.Sun ->
            "Sun"


toMonthString : Time.Month -> String
toMonthString month =
    case month of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"


type Period
    = AM
    | PM


periodToString : Period -> String
periodToString period =
    case period of
        AM ->
            "a.m."

        PM ->
            "p.m."


dateAndTime : Model -> String
dateAndTime model =
    let
        day : String
        day =
            Time.toDay model.zone model.time
                |> String.fromInt

        weekday : String
        weekday =
            Time.toWeekday model.zone model.time
                |> toWeekdayString

        month : String
        month =
            Time.toMonth model.zone model.time
                |> toMonthString

        year : String
        year =
            Time.toYear model.zone model.time
                |> String.fromInt

        parsedHour : { hour : Int, period : Period }
        parsedHour =
            parseHour model.zone model.time

        hour : String
        hour =
            parsedHour.hour
                |> String.fromInt

        period : String
        period =
            parsedHour.period
                |> periodToString

        minute : String
        minute =
            Time.toMinute model.zone model.time
                |> String.fromInt
                |> String.padLeft 2 '0'
    in
    weekday
        ++ ", "
        ++ month
        ++ " "
        ++ day
        ++ ", "
        ++ year
        ++ " "
        ++ hour
        ++ ":"
        ++ minute
        ++ " "
        ++ period
