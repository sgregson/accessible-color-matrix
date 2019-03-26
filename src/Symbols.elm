module Symbols exposing (..)

import Svg as S
import Svg.Attributes as SA

badContrastId = "usa-matrix-bad-contrast-ratio"
badContrastHref = "#" ++ badContrastId

symbols : S.Svg msg
symbols =
  S.svg [ SA.class "usa-matrix-symbol-definitions" ]
    [ S.symbol [ SA.id badContrastId
               , SA.viewBox "0 0 100 100" ]
      [ S.rect [ SA.width "100"
               , SA.height "100"
               , SA.fill "rgba(240,240,240,.5)" ] []
      , S.line [ SA.x1 "0"
               , SA.y1 "100"
               , SA.x2 "100"
               , SA.y2 "0"
               , SA.stroke "white"
               , SA.strokeWidth "4" ] []
      ]
    ]

badContrastSvg : String -> String -> S.Svg msg
badContrastSvg className text =
  let
    attrs = if className == "" then [] else [ SA.class className ]
  in
    S.svg attrs 
      [ S.use [ SA.xlinkHref badContrastHref ] []
      , S.text_ [SA.x "15"
                , SA.y "40"
                , SA.textAnchor "left"
                , SA.fill "currentColor"] [S.text text] ]
