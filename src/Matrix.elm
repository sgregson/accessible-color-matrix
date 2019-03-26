module Matrix exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, scope, style, title, attribute)
import Color exposing (white)

import Symbols exposing (symbols, badContrastSvg)
import Accessibility exposing (ariaHidden, role)
import ContrastRatio exposing (
  contrastRatio, areColorsIndistinguishable, humanFriendlyContrastRatio
  )
import Palette exposing (
  Palette, PaletteEntry, paletteEntryHex, squareBgStyle
  )

highRatioThreshold : Float
highRatioThreshold = 4.5

lowRatioThreshold : Float
lowRatioThreshold = 3

badContrastLegendText : String
badContrastLegendText =
  "Do not use these color combinations; they do not meet the minimum color contrast ratio of " ++
    toString (lowRatioThreshold) ++ """:1, so they do not conform with the standards of
  WCAG 2 for body text. This means that some people would have
  difficulty reading the text. Employing accessibility best practices
  improves the user experience for all users."""

largeContrastLegendText : String
largeContrastLegendText =
  """These color combindations can only be used on large text blocks.
  Per WCAG2.1 Large Text is '18pt (24px) or 14pt (19px) bold font size.'
  """


badContrastText : PaletteEntry -> PaletteEntry -> Float -> String
badContrastText background foreground ratio =
  "Do not use " ++ foreground.name ++ " text on " ++ background.name ++
    " background; it is not WCAG2-compliant, with a contrast ratio of " ++
      (humanFriendlyContrastRatio ratio) ++ "."

goodContrastText : PaletteEntry -> PaletteEntry -> Float -> String
goodContrastText background foreground ratio =
  "The contrast ratio of " ++ foreground.name ++ " on " ++ background.name ++
    " is " ++ (humanFriendlyContrastRatio ratio) ++ "."

legend : Html msg
legend =
  div [] 
    [ div [ class "usa-matrix-legend" ]
      [ div [class "usa-matrix-square"] [badContrastSvg "" ""]
      , p [ class "usa-sr-invisible", ariaHidden True ]
          [ Html.text badContrastLegendText ]
      ]
    , div [ class "usa-matrix-legend" ]
      [ div [
        class "usa-matrix-square"
        , attribute "data-textSize" "Large+"
        , style [("box-shadow", "inset 0 0 0 1px #aeb0b5")]
        ] [text "##:##"]
      , p [ class "usa-sr-invisible", ariaHidden True ]
          [ Html.text largeContrastLegendText ]
      ]
    ]

capFirst : String -> String
capFirst str =
  (String.toUpper (String.left 1 str)) ++ (String.dropLeft 1 str)

matrixTableHeader : Palette -> Html msg
matrixTableHeader palette =
  let
    fgStyle : PaletteEntry -> List (String, String)
    fgStyle entry =
      [ ("color", paletteEntryHex entry) ] ++
        if areColorsIndistinguishable entry.color white then
          -- https://css-tricks.com/adding-stroke-to-web-text/
          [ ("text-shadow"
            ,"-1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, " ++
             "1px 1px 0 #000") ]
          else []

    headerCell : PaletteEntry -> Html msg
    headerCell entry =
      td [ scope "col" ]
        [ div [ class "usa-matrix-desc" ]
          [ text (capFirst entry.name)
          , text " text"
          , br [] []
          , small [] [ text (paletteEntryHex entry) ]
          ]
        , strong [ class "usa-sr-invisible"
                 , ariaHidden True
                 , style (fgStyle entry) ]
          [ text "Aa" ]
        ]
  in
    thead []
      [ tr []
        ([ td [ scope "col" ] [] ] ++ List.map headerCell palette)
      ]

matrixTableRow : Palette -> Html msg
matrixTableRow palette =
  let
    rowHeaderCell : PaletteEntry -> Html msg
    rowHeaderCell entry =
      td [ scope "row" ]
        [ div []
          [ div [ class "usa-matrix-square"
                , style (squareBgStyle entry) ] []
          , div [ class "usa-matrix-desc" ]
            [ text (capFirst entry.name)
            , text " background"
            , br [] []
            , small [] [ text (paletteEntryHex entry) ]
            ]
          ]
        ]

    rowComboCell : PaletteEntry -> PaletteEntry -> Html msg
    rowComboCell background foreground =
      let
        ratio : Float
        ratio = contrastRatio background.color foreground.color

        validCell : Html msg
        validCell =
          td [ class "usa-matrix-valid-color-combo" ]
            [ div [ class "usa-matrix-square"
                  , style (squareBgStyle background)
                  , title (goodContrastText background foreground ratio)
                  , role "presentation"
                  , attribute "data-textSize" (if ratio < highRatioThreshold then "Large+" else "")
                  , style [("color", paletteEntryHex foreground)] ]
                [ strong [ class "usa-sr-invisible"
                         , ariaHidden True]
                    [ text (humanFriendlyContrastRatio ratio) ]
                ]
            , div [ class "usa-matrix-color-combo-description" ]
              [ strong [] [ text (capFirst foreground.name) ]
              , text " text on "
              , strong [] [ text (capFirst background.name) ]
              , text " background"
              , span [ class "usa-sr-only" ]
                [ text " is WCAG2-compliant, with a contrast ratio of "
                , text (humanFriendlyContrastRatio ratio)
                , text "."
                ]
              , text (if ratio < highRatioThreshold then " can only be used on large text" else "")
              ]
            ]

        invalidCell : Html msg
        invalidCell =
          let
            desc = badContrastText background foreground ratio
          in
            td [ class "usa-matrix-invalid-color-combo" ]
              [ div [ role "presentation"
              , title desc
              , style [("color",  "#ddd")]  ]
                [ badContrastSvg "usa-matrix-square" (humanFriendlyContrastRatio ratio) ]
              , div [ class "usa-sr-only" ] [ text desc ]
              ]
      in
        if ratio >= lowRatioThreshold then validCell else invalidCell

    row : Palette -> PaletteEntry -> Html msg
    row palette background =
      tr []
        ([ rowHeaderCell background ] ++
          List.map (rowComboCell background) palette)
  in
    tbody [] (List.map (row palette) (List.reverse palette))

matrixTable : Palette -> Html msg
matrixTable palette =
  table [ class "usa-table-borderless usa-matrix" ]
    [ matrixTableHeader palette
    , matrixTableRow palette
    ]

matrixDiv : Palette -> Html msg
matrixDiv palette =
  div []
    [ symbols
    , legend
    , matrixTable palette
    ]
