module DeltaHop where
{-| TodoMVC implemented in Elm, using plain HTML and CSS for rendering.

This application is broken up into four distinct parts:

  1. Model  - a full definition of the application's state
  2. Update - a way to step the application state forward
  3. View   - a way to visualize our application state with HTML
  4. Inputs - the signals necessary to manage events

This clean division of concerns is a core part of Elm. You can read more about
this in the Pong tutorial: http://elm-lang.org/blog/Pong.elm

This program is not particularly large, so definitely see the following
document for notes on structuring more complex GUIs with Elm:
https://gist.github.com/evancz/2b2ba366cae1887fe621
-}

import String
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import Html.Tags (..)
import Html.Optimize.RefEq as Ref
import Maybe
import Window

import Graphics.Input
import Graphics.Input as Input


---- MODEL ----

-- The full application state of our todo app.

-- type nanosecs = (asText . Date.second) <~ (lift Date.fromTime (every second))

type State =
    { 
    seconds    : Float,
    timers     : [Timer], 
    field      : String, 
    uid        : Int, 
    visibility : String
    }

type Timer =
    { 
    startTime   : Float,
    stopTime    : Float,
    description : String, 
    completed   : Bool, 
    editing     : Bool, 
    running     : Bool,
    id          : Int
    }

newTimer : String -> Int -> Float -> Timer
newTimer desc id time =
    { 
    startTime = time,
    stopTime = 0,
    description = desc, 
    completed = False, 
    editing = False, 
    running = True, 
    id = id
    }

emptyState : State
emptyState =
    { 
    seconds = 0,
    timers = [], 
    visibility = "All", 
    field = "", 
    uid = 0
    }


---- UPDATE ----

-- A description of the kinds of actions that can be performed on the state of
-- the application. See the following post for more info on this pattern and
-- some alternatives: https://gist.github.com/evancz/2b2ba366cae1887fe621
data Action
    = NoOp
    | Add Float
    | StartStop Int Bool Float
    | UpdateField String
    | EditingTimer Int Bool
    | UpdateTimer Int String
    | Delete Int
    | DeleteComplete
    | Check Int Bool
    | CheckAll Bool
    | ChangeVisibility String

-- How we step the state forward for any given action
step : Action -> State -> State
step action state =
    case action of
      NoOp -> state


      Add currentTime ->
          { state | uid <- state.uid + 1
                  , field <- ""
                  , timers <- if String.isEmpty state.field
                               then state.timers
                               else state.timers ++ [newTimer state.field state.uid currentTime]
          }

      StartStop id isRunning currentTime ->
          let update t = if t.id == id then
              if isRunning /= t.running then {
                t | running <- isRunning,
                    stopTime <- if isRunning then 0 else currentTime,
                    startTime <- if isRunning then currentTime - (t.stopTime - t.startTime) else t.startTime
              }
              else t
          else t in  { state | timers <- map update state.timers }
          
      UpdateField str ->
          { state | field <- str }

      EditingTimer id isEditing ->
          let update t = if t.id == id then { t | editing <- isEditing } else t
          in  { state | timers <- map update state.timers }

      UpdateTimer id timer ->
          let update t = if t.id == id then { t | description <- timer } else t
          in  { state | timers <- map update state.timers }

      Delete id ->
          { state | timers <- filter (\t -> t.id /= id) state.timers }

      DeleteComplete ->
          { state | timers <- filter (not << .completed) state.timers }

      Check id isCompleted ->
          let update t = if t.id == id then { t | completed <- isCompleted } else t
          in  { state | timers <- map update state.timers }

      CheckAll isCompleted ->
          let update t = { t | completed <- isCompleted } in
          { state | timers <- map update state.timers }

      ChangeVisibility visibility ->
          { state | visibility <- visibility }


---- VIEW ----

view : State -> Float -> Html
view state s =
    div
      [ class "todomvc-wrapper"
      , style [ prop "visibility" "hidden" ]
      ]
      [ section
          [ id "todoapp" ]
          [ Ref.lazy2 timerEntry state.field s
          , Ref.lazy3 timerList state.visibility state.timers s
          , Ref.lazy2 controls state.visibility state.timers
          ]
      , infoFooter
      ]

onEnter : Input.Handle a -> a -> Attribute
onEnter handle value =
    on "keydown" (when (\k -> k.keyCode == 13) getKeyboardEvent) handle (always value)

timerEntry : String -> Float -> Html
timerEntry timer s =
    header 
      [ id "header" ]
      [ h1 [] [ text "delta-hop" ]
      , input
          [ id "new-todo"
          , placeholder "What needs to be done?"
          , autofocus True
          , value timer
          , name "newTodo"
          , on "input" getValue actions.handle UpdateField
          , onEnter actions.handle (Add s)
          ]
          []
      ]

timerList : String -> [Timer] -> Float -> Html
timerList visibility timers s =
    let isVisible todo =
            case visibility of
              "Completed" -> todo.completed
              "Active" -> not todo.completed
              "All" -> True

        allCompleted = all .completed timers

        cssVisibility = if isEmpty timers then "hidden" else "visible"
    in
    section
      [ id "main"
      , style [ prop "visibility" cssVisibility ]
      ]
      [ input
          [ id "toggle-all"
          , type' "checkbox"
          , name "toggle"
          , checked allCompleted
          , onclick actions.handle (\_ -> CheckAll (not allCompleted))
          ]
          []
      , label
          [ for "toggle-all" ]
          [ text "Mark all as complete" ]
      , ul
          [ id "todo-list" ]
          (map (todoItem s) (filter isVisible timers))
      ]

todoItem : Float -> Timer -> Html
todoItem s todo =
    let className = (if todo.completed then "completed " else "") ++
                    (if todo.editing   then "editing"    else "")
    in

    li
      [ class className ]
      [ div
          [ class "view" ]
          [ input
              [ class "toggle"
              , type' "checkbox"
              , checked todo.completed
              , onclick actions.handle (\_ -> StartStop todo.id (not todo.running) s)
              ]
              []
          , label
              [ ondblclick actions.handle (\_ -> EditingTimer todo.id True) ]
              [ text <| show <| s ]
          , button
              [ class "destroy"
              , onclick actions.handle (always (Delete todo.id))
              ]
              []
          ]
      , input
          [ class "edit"
          , value todo.description
          , name "title"
          , id ("todo-" ++ show todo.id)
          , on "input" getValue actions.handle (UpdateTimer todo.id)
          , onblur actions.handle (EditingTimer todo.id False)
          , onEnter actions.handle (EditingTimer todo.id False)
          ]
          []
      ]

controls : String -> [Timer] -> Html
controls visibility timers =
    let timersCompleted = length (filter .completed timers)
        timersLeft = length timers - timersCompleted
        item_ = if timersLeft == 1 then " item" else " items"
    in
    footer
      [ id "footer"
      , hidden (isEmpty timers)
      ]
      [ span
          [ id "todo-count" ]
          [ strong [] [ text (show timersLeft) ]
          , text (item_ ++ " left")
          ]
      , ul
          [ id "filters" ]
          [ visibilitySwap "#/" "All" visibility
          , text " "
          , visibilitySwap "#/active" "Active" visibility
          , text " "
          , visibilitySwap "#/completed" "Completed" visibility
          ]
      , button
          [ class "clear-completed"
          , id "clear-completed"
          , hidden (timersCompleted == 0)
          , onclick actions.handle (always DeleteComplete)
          ]
          [ text ("Clear completed (" ++ show timersCompleted ++ ")") ]
      ]

visibilitySwap : String -> String -> String -> Html
visibilitySwap uri visibility actualVisibility =
    let className = if visibility == actualVisibility then "selected" else "" in
    li
      [ onclick actions.handle (always (ChangeVisibility visibility)) ]
      [ a [ class className, href uri ] [ text visibility ] ]

infoFooter : Html
infoFooter =
    footer [ id "info" ]
      [ p [] [ text "Double-click to edit a timer" ]
      , p [] [ text "Written by "
             , a [ href "https://github.com/mindw0rk" ] [ text "Karolis Stasaitis" ]
             ]
      ]


---- INPUTS ----

-- wire the entire application together
main : Signal Element
main = lift3 scene state Window.dimensions (every 1)

scene : State -> (Int,Int) -> Float -> Element
scene state (w,h) s = container w h midTop (toElement 550 h (view state s))

-- manage the state of our application over time
state : Signal State
state = foldp step startingState actions.signal

startingState : State
startingState = Maybe.maybe emptyState identity getStorage

-- actions from user input
actions : Input.Input Action
actions = Input.input NoOp

port focus : Signal String
port focus =
    let needsFocus act =
            case act of
              EditingTimer id bool -> bool
              _ -> False

        toSelector (EditingTimer id _) = ("#todo-" ++ show id)
    in
        toSelector <~ keepIf needsFocus (EditingTimer 0 True) actions.signal

-- interactions with localStorage to save app state
port getStorage : Maybe State

port setStorage : Signal State
port setStorage = state