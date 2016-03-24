;; HALOBACTIERUM PURPLE MEMBRANE BIOGENESIS MODEL
;; 
;; Author: Patrick Mar, Institute for Systems Biology
;; Created: August 23, 2005
;; Last Modified: August 23, 2005
;;
;; Other Contributors: Professor Nitin Baliga, Dr. Marc Facciotti, Dr. Kenia Whitehead, 
;; Dan Gallagher, Paul Shannon


;; ***** VARIABLE DECLARATIONS *****

breeds
[ nodes edges edge-heads edge-bodies ]

globals
[ edges-data network-data catalytic-amount1 catalytic-amount2 change 
  bat-ko-status crtb1-ko-status brp-ko-status bop-ko-status selectable ]

nodes-own
[ name amount in-edges out-edges knockedout? nodetype ]
;;available nodetypes: control, protein, metabolite, bacterioRhodopsin

edges-own
[ from into edge_type ]

edge-heads-own [parent-edge]
edge-bodies-own [parent-edge]



;; ***** SETUP PROCEDURES *****

to setup
  ca
  ask patches [ set pcolor 39 ]   ;; set background color
  setup-nodes
  setup-edges
  set bat-ko-status false
  set crtb1-ko-status false
  set brp-ko-status false
  set bop-ko-status false
end 


to setup-nodes
  ;; set globals
  set catalytic-amount1 0
  set catalytic-amount2 0
  
  ;; create the nodes
  create-custom-nodes 12
    [ set in-edges []
      set out-edges []
      set knockedout? false 
      set amount 0 ]
  
  ;; customize individual nodes
  
  ;; oxygen
  ask nodes with [ who = 0 ] [ set name "light" 
                               set nodetype "control"
                               setxy (0.2 * screen-edge-x) (0.8 * screen-edge-y) 
                               set amount oxygen-amount
                               ]      
  
  ;; light
  ask nodes with [ who = 1 ] [ set name "oxygen" 
                               set nodetype "control"
                               setxy (-0.2 * screen-edge-x) (0.8 * screen-edge-y) 
                               set amount light-amount
                               ]
  
  ;; bat
  ask nodes with [ who = 2 ] [ set name "bat" 
                               set nodetype "protein"
                               setxy (0.0 * screen-edge-x) (0.6 * screen-edge-y) 
                              ]
  
  ;; crtb1
  ask nodes with [ who = 3 ] [ set name "crtb1" 
                               set nodetype "protein"
                               setxy (0.67 * screen-edge-x) (0.5 * screen-edge-y) ] 
  
  ;; brp
  ask nodes with [ who = 4 ] [ set name "brp" 
                               set nodetype "protein"
                               setxy (0.48 * screen-edge-x) (-0.45 * screen-edge-y) ]
  
  ;; bop
  ask nodes with [ who = 5 ] [ set name "bop" 
                               set nodetype "protein"
                               setxy (-0.8 * screen-edge-x) (0.0 * screen-edge-y) 
                             ]
  
  ;; geranylGeranylPP
  ask nodes with [ who = 6 ] [ set name "geranylGeranylPP" 
                               set nodetype "metabolite"
                               setxy (0.8 * screen-edge-x) (0.8 * screen-edge-y)
                              ]
  
  ;; phytoene
  ask nodes with [ who = 7 ] [ set name "phytoene" 
                               set nodetype "metabolite"
                               setxy (0.8 * screen-edge-x) (0.4 * screen-edge-y) 
                               ]
   
  ;; lycopene
  ask nodes with [ who = 8 ] [ set name "lycopene" 
                               set nodetype "metabolite"
                               setxy (0.8 * screen-edge-x) (0.0 * screen-edge-y) 
                               ]
  
  ;; betaCarotene
  ask nodes with [ who = 9 ] [ set name "betaCarotene" 
                               set nodetype "metabolite"
                               setxy (0.8 * screen-edge-x) (-0.3 * screen-edge-y) 
                               ]
  
  ;; retinal
  ask nodes with [ who = 10 ] [ set name "retinal" 
                                set nodetype "metabolite"
                                setxy (0.3 * screen-edge-x) (-0.6 * screen-edge-y) 
                                ]
                                
  
  ;; bacterioRhodopsin
  ask nodes with [ who = 11] [ set name "bacterioRhodopsin" 
                               set nodetype "bacterioRhodopsin"
                               setxy (0.0 * screen-edge-x) (-0.8 * screen-edge-y) ]
                               
   
  ;; set shapes 
  ask nodes with [ nodetype = "control" ] [ set shape "triangle" ]
  ask nodes with [ nodetype = "protein" ] [ set shape "square" ]
  ask nodes with [ nodetype = "metabolite" ] [ set shape "circle" ]
  ask nodes with [ nodetype = "bacterioRhodopsin" ] [ set shape "octagon" ] 
  set-default-shape edge-heads "edge-heads"
  set-default-shape edge-bodies "edge-bodies"
  
  ;; set general node variables  
  ask nodes [set label name 
             set label-color black]   
  
  ;; update physical amounts of each node
  update-nodes
end


to setup-edges
  ;; define edge parts
  set-default-shape edges "line"
  set-default-shape edge-heads "edge-heads"
  set-default-shape edge-bodies "edge-bodies"
  
  ;; definte node connections
  ask nodes with [ name = "light" ] [ connect-to (turtle 2) "catalytic" ]
  ask nodes with [ name = "oxygen" ] [ connect-to (turtle 2) "catalytic" ]
  ask nodes with [ name = "bat" ] [ connect-to (turtle 3) "catalytic" 
                                    connect-to (turtle 4) "catalytic"
                                    connect-to (turtle 5) "catalytic" ]
  ask nodes with [ name = "bop" ] [ connect-to (turtle 11) "metabolitic" ]
  ask nodes with [ name = "geranylGeranylPP" ] [ connect-to (turtle 7) "metabolitic" ]
  ask nodes with [ name = "phytoene" ] [ connect-to (turtle 8) "metabolitic" ]
  ask nodes with [ name = "lycopene" ] [ connect-to (turtle 9) "metabolitic" ]
  ask nodes with [ name = "betaCarotene" ] [ connect-to (turtle 10) "metabolitic" ]
  ask nodes with [ name = "retinal" ] [ connect-to (turtle 11) "metabolitic" ]
end


to connect-to [other-node edge-type]  ;; node procedure
  hatch-edges 1
    [ set label no-label
      
      ;; set edge color
      if edge-type = "catalytic" [ set color red ]
      if edge-type = "metabolitic" [ set color green ]
      
      ;; set edge direction
      set from myself
      set into other-node
      
      ;; add edge to edge lists of both nodes
      set (out-edges-of from) lput self (out-edges-of from)
      set (in-edges-of into) lput self (in-edges-of into)
      
      ;; position the edge
      reposition ]
end             


to reposition  ;; edge procedure
  ;; turn off display while positioning edge
  no-display

  ;; edge starting point
  setxy (xcor-of from) (ycor-of from)
  
  ;; make sure edge doesn't fall exactly on top of node
  if distance into = 0 [ask into [fd 1]]  
 
  ;; set edge heading
  set heading towards-nowrap into

  ;; set edge size
  set size distance-nowrap into - (size-of into / 2)

  ;; definte edge parts
  jump (distance-nowrap into) / 2  
  ask edge-heads with [parent-edge = myself] [die]
  ask edge-bodies with [parent-edge = myself] [die]
  hatch-edge-heads 1 [
   set parent-edge myself
   set size 1.5
   jump size-of parent-edge / 2 - size / 2
  ]
  hatch-edge-bodies 1 [
    set parent-edge myself
    set size 1
  ]
 
  ;; turn display back on
  display
end


;; ***** RUNTIME PROCEDURES *****

to go
    update-nodes
    use-mouse
end 


to update-nodes 
  ask nodes with [ name = "light" ] [ set amount light-amount ] 
  ask nodes with [ name = "oxygen" ] [ set amount oxygen-amount ]
  wait .1 ;; put in artificial delay
  ask nodes with [ name = "bat" ] [ ifelse knockedout? = true [ set amount 0 ]  
                                  [ set amount (((100 - oxygen-amount) * (light-amount + 20)) / 100) ]]
  wait .07
  ask nodes with [ name = "crtb1" or name = "brp" or name = "bop" ] [ ifelse knockedout? = true [ set amount 0 ]
                                                                    [ set amount (amount-of turtle 2)]]  
  
  ask nodes with [ name = "geranylGeranylPP" ] [ set amount 100 ]
  set catalytic-amount1 (((amount-of turtle 3) / 100) * (amount-of turtle 6))
  wait .04
  ask nodes with [ name = "phytoene" ] [ ifelse knockedout? = true [ set amount 0 ]
                                       [ set amount catalytic-amount1 
                                         ask turtle 6 [ set amount (amount - catalytic-amount1) ]]]
  wait .02
  ask nodes with [ name = "lycopene" ] [ ifelse knockedout? = true [ set amount 0 ]
                                       [ set amount catalytic-amount1 ]]
  wait .01
  ask nodes with [ name = "betaCarotene" ] [ ifelse knockedout? = true [ set amount 0 ]
                                           [ set amount catalytic-amount1 ]]
  set catalytic-amount2 (((amount-of turtle 4) / 100) * (amount-of turtle 9))
  wait .01
  ask nodes with [ name = "retinal" ] [ ifelse knockedout? = true [ set amount 0 ]
                                      [ set amount catalytic-amount2 ]]
  wait .02
  ask nodes with [ name = "bacterioRhodopsin" ] [ ifelse knockedout? = true [set amount 0 ] [ 
                                         ifelse (amount-of turtle 5) > (amount-of turtle 10)
                                         [ set amount amount-of turtle 10 ]
                                         [ set amount amount-of turtle 5 ] ] ]                                       
  ask nodes [ update-display ]
end


to update-display ;; node procedure
  ;; set sizes
  set size ((amount / 25) + 1.5)
  
  ;; set colors
  ifelse knockedout? = true [ set color 39 ] [
    if nodetype = "control"  [ set color scale-color yellow amount 220 -20]
    if nodetype = "protein"  [ set color white ]
    if nodetype = "metabolite" [ ;;set color scale-color orange amount 220 -20 ]
                                  if name = "geranylGeranylPP" [ set color scale-color 29 amount 570 -20 ]
                                  if name = "phytoene" [ set color scale-color 19 amount 470 -20 ]
                                  if name = "lycopene" [ set color scale-color red amount 280 -20 ]
                                  if name = "betaCarotene" [ set color scale-color orange amount 280 -20 ]
                                  if name = "retinal" [ set color scale-color yellow amount 300 -20 ]
                               ]
    if nodetype = "bacterioRhodopsin" [ set color scale-color violet amount 220 -20 ]]
end


;; ***** KNOCKOUT PROCEDURES *****

to knockout [ nodename ]
  if nodename = "bat" [ toggle-bat true set bat-ko-status true]
  if nodename = "crtb1" [ toggle-crtb1 true set crtb1-ko-status true ]
  if nodename = "brp" [ toggle-brp true set brp-ko-status true ]
  if nodename = "bop" [ toggle-bop true set bop-ko-status true ]
end


to reactivate [ nodename ] 
  if nodename = "bat" [ toggle-bat false set bat-ko-status false ]
  if nodename = "crtb1" [ toggle-crtb1 false set crtb1-ko-status false ]
  if nodename = "brp" [ toggle-brp false set brp-ko-status false ]
  if nodename = "bop" [ toggle-bop false set bop-ko-status false ]
  
  if bat-ko-status = true [ toggle-bat true ]
  if crtb1-ko-status = true [ toggle-crtb1 true ]
  if brp-ko-status = true [ toggle-brp true ]
  if bop-ko-status = true [ toggle-bop true ]
end


to reactivate-all 
  reactivate "bat"
  reactivate "crtb1"
  reactivate "bop"
  reactivate "brp"
end


;; toggles bat between knockout and reactivate 
;; knockout when change-value is true
;; reactivate when change-value is false
to toggle-bat [ change-value ]
  ask nodes with [ name = "bat" or
                   name = "crtb1" or
                   name = "bop" or
                   name = "phytoene" or
                   name = "lycopene" or
                   name = "betaCarotene" or
                   name = "brp" or
                   name = "retinal" or
                   name = "bacterioRhodopsin" ] [ set knockedout? change-value ]
end


;; similar to above
to toggle-crtb1 [ change-value ]
  ask nodes with [ name = "crtb1" or
                   name = "phytoene" or
                   name = "lycopene" or
                   name = "betaCarotene" or
                   name = "retinal" or
                   name = "bacterioRhodopsin" ] [ set knockedout? change-value ]                                                                 
end


to toggle-brp [ change-value ]
  ask nodes with [ name = "brp" or name = "retinal" or name = "bacterioRhodopsin"] [ set knockedout? change-value ]
end


to toggle-bop [ change-value ]
  ask nodes with [ name = "bop" or name = "bacterioRhodopsin"] [ set knockedout? change-value ]
end


;; ***** MOUSE INPUT PROCEDURES *****

to use-mouse
  let selectables turtles with [ breed = nodes ] 
  ask selectables with [round mouse-xcor = round xcor and round mouse-ycor = round ycor  
  ;; shape changes to "selectable" form when moused-over, exclude those already selected
  and not member? "selectable" shape ]
  ;; make string with current shape and "selectable" to define new shape
  [set shape word "selectable" shape 
   set selectable self 
   ;; print description of node
   print-description self ]
  ask turtles with [member? "selectable" shape][
    if round mouse-xcor != round xcor or round mouse-ycor != round ycor
      ;; return shape to original form if mouse not at location
      [set shape remove "selectable" shape set selectable []]
  ]
  
  ;; listen for mouse activated knockouts
  ask selectables [ if mouse-down? and selectable = self and (nodetype-of self) = "protein" [
    knockout name-of self
  ]]
    
end


;; ***** OUTPUT PROCEDURES *****

to print-description [ node ]
  clear-output
  output-print "Description: " + (name-of node)
  if (name-of node) = "light" [ output-print "Light increases the production of bat." ]
  if (name-of node) = "oxygen" [ output-print "Oxygen inhibits the production of bat." ]
  if (name-of node) = "geranylGeranylPP" [ output-print "geranylGeranylPP is a light reddish metabolite." ]
  if (name-of node) = "bat" [ output-print "'bat' is a gene that encodes the protein 'Bat'.  This protein is a 'transcription regulator' " output-print "that controls transcription of the genes brp, bop, and crtb1.  Bat is believed to impose " output-print "this control by sensing two environmental factors -Light and Oxygen." ]
  if (name-of node) = "crtb1" [ output-print "'crtB1' is a gene that encodes the protein 'CrtB1'.  This protein is an enzyme that catalyzes " output-print "conversion of geranylGeranylPP to phytoene." ]
  if (name-of node) = "brp" [ output-print "'brp' is a gene that encodes the protein 'Brp'.  This protein is an enzyme that catalyzes " output-print "conversion of betaCarotene to retinal." ]
  if (name-of node) = "bop" [ output-print "'bop' is a gene that encodes the protein 'Bop' or bacterioopsin.  This protein complexes with " output-print "retinal in a 1:1 stoichiometry (ratio) to give bacteriorhodopsin." ]
  if (name-of node) = "bacterioRhodopsin" [ output-print "bacteriorhodopsin absorbs light and produces a gradient across the outer membrane " output-print "of an organism.  It gives halobacterium its purplish color." ]
  if (name-of node) = "phytoene" [ output-print "phytoene is a reddish-orangish carotenoid. Along with lycopene, it is plentiful in tomatoes." ]
  if (name-of node) = "lycopene" [ output-print "lycopene is a member of the carotenoid family of organic pigments.  The reddish hue of " output-print "lycopene is what gives tomatoes their reddish color." ]
  if (name-of node) = "betaCarotene" [ output-print "betaCarotene is a member of the carotenoid family of organic pigments.  It is important" output-print "in photosynthesis and gives carrots their orange color.  Also, it is a major component of vitamin A." ]
  if (name-of node) = "retinal" [ output-print "retinal is a derivative of vitamin A.  It is particularly good at absorbing light and is one of " output-print "primary requirements of eyesight." ]
  output-print "\n"
end



















@#$#@#$#@
GRAPHICS-WINDOW
310
10
755
476
17
17
12.43
1
10
1
1
1
0

CC-WINDOW
5
712
765
807
Command Center

SLIDER
24
11
292
44
light-amount
light-amount
0
100
49
1
1
%

SLIDER
24
58
292
91
oxygen-amount
oxygen-amount
0
100
0
1
1
%

BUTTON
48
105
137
138
start/reset
setup
NIL
1
T
OBSERVER
T
NIL

BUTTON
167
105
254
138
NIL
go
T
1
T
OBSERVER
T
NIL

BUTTON
23
152
139
185
knockout bat
knockout "bat"
NIL
1
T
OBSERVER
T
NIL

BUTTON
23
199
140
232
knockout crtb1
knockout "crtb1"
NIL
1
T
OBSERVER
T
NIL

BUTTON
23
246
141
279
knockout brp
knockout "brp"
NIL
1
T
OBSERVER
T
NIL

BUTTON
23
292
142
325
knockout bop
knockout "bop"
NIL
1
T
OBSERVER
T
NIL

BUTTON
167
153
292
186
reactivate bat
reactivate "bat"
NIL
1
T
OBSERVER
T
NIL

BUTTON
167
199
292
232
reactivate crtb1
reactivate "crtb1"
NIL
1
T
OBSERVER
T
NIL

BUTTON
167
246
291
279
reactivate brp
reactivate "brp"
NIL
1
T
OBSERVER
T
NIL

BUTTON
168
292
291
325
reactivate bop
reactivate "bop"
NIL
1
T
OBSERVER
T
NIL

BUTTON
91
341
222
374
reactivate all 
reactivate-all
NIL
1
T
OBSERVER
T
NIL

OUTPUT
19
500
756
698

BUTTON
21
459
146
492
Clear 
clear-output
NIL
1
T
OBSERVER
T
NIL

@#$#@#$#@
WHAT IS IT?
-----------
This section could give a general understanding of what the model is trying to show or explain.


HOW IT WORKS
------------
This section could explain what rules the agents use to create the overall behavior of the model.


HOW TO USE IT
-------------
This section could explain how to use the model, including a description of each of the items in the interface tab.


THINGS TO NOTICE
----------------
This section could give some ideas of things for the user to notice while running the model.


THINGS TO TRY
-------------
This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.


EXTENDING THE MODEL
-------------------
This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.


NETLOGO FEATURES
----------------
This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.


RELATED MODELS
--------------
This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.


CREDITS AND REFERENCES
----------------------
This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7566196 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7566196 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7566196 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7566196 true true 150 285 285 225 285 75 150 135
Polygon -7566196 true true 150 135 15 75 150 15 285 75
Polygon -7566196 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7566196 true true 96 182 108
Circle -7566196 true true 110 127 80
Circle -7566196 true true 110 75 80
Line -7566196 true 150 100 80 30
Line -7566196 true 150 100 220 30

butterfly
true
0
Polygon -7566196 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7566196 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7566196 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7566196 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7566196 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7566196 true true 47 195 58
Circle -7566196 true true 195 195 58

circle
false
0
Circle -7566196 true true 30 30 240

cow
false
0
Polygon -7566196 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7566196 true true 73 210 86 251 62 249 48 208
Polygon -7566196 true true 25 114 16 195 9 204 23 213 25 200 39 123

edge-bodies
true
0
Polygon -7500403 false true 135 105 165 105 165 135 180 135 180 165 165 165 165 195 135 195 135 165 120 165 120 135 135 135

edge-heads
true
0
Polygon -7500403 true true 45 255 150 0 255 255 150 225

face happy
false
0
Circle -7566196 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7566196 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7566196 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7566196 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7566196 true true 60 15 75 300
Polygon -7566196 true true 90 150 270 90 90 30
Line -7566196 true 75 135 90 135
Line -7566196 true 75 45 90 45

flower
false
0
Polygon -11352576 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7566196 true true 85 132 38
Circle -7566196 true true 130 147 38
Circle -7566196 true true 192 85 38
Circle -7566196 true true 85 40 38
Circle -7566196 true true 177 40 38
Circle -7566196 true true 177 132 38
Circle -7566196 true true 70 85 38
Circle -7566196 true true 130 25 38
Circle -7566196 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -11352576 true false 189 233 219 188 249 173 279 188 234 218
Polygon -11352576 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7566196 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7566196 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7566196 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7566196 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7566196 true 150 0 150 300

octagon
false
0
Polygon -7566196 true true 90 15 210 15 285 90 285 210 210 285 90 285 15 210 15 90 90 15 180 120 90 15

pentagon
false
0
Polygon -7566196 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7566196 true true 110 5 80
Polygon -7566196 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7566196 true true 127 79 172 94
Polygon -7566196 true true 195 90 240 150 225 180 165 105
Polygon -7566196 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7566196 true true 135 90 165 300
Polygon -7566196 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7566196 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7566196 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7566196 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7566196 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7566196 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7566196 true true 135 90 120 45 150 15 180 45 165 90

selectablecircle
false
0
Circle -7566196 true true 16 16 270
Circle -16711936 true false 46 46 210

selectableoctagon
false
0
Polygon -7566196 true true 90 15 210 15 285 90 285 210 210 285 90 285 15 210 15 90 90 15 180 120 90 15
Circle -7566196 false true 84 24 42
Circle -16711936 true false 30 30 240

selectablesquare
false
0
Rectangle -7566196 true true 30 30 270 270
Rectangle -16711936 true false 60 60 240 240

selectabletriangle
false
0
Polygon -7566196 true true 150 30 15 255 285 255
Polygon -16711936 true false 151 99 225 223 75 224

square
false
0
Rectangle -7566196 true true 30 30 270 270

star
false
0
Polygon -7566196 true true 60 270 150 0 240 270 15 105 285 105
Polygon -7566196 true true 75 120 105 210 195 210 225 120 150 75

target
false
0
Circle -7566196 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7566196 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7566196 true true 120 120 60

tree
false
0
Circle -7566196 true true 118 3 94
Rectangle -6524078 true false 120 195 180 300
Circle -7566196 true true 65 21 108
Circle -7566196 true true 116 41 127
Circle -7566196 true true 45 90 120
Circle -7566196 true true 104 74 152

triangle
false
0
Polygon -7566196 true true 150 30 15 255 285 255

truck
false
0
Rectangle -7566196 true true 4 45 195 187
Polygon -7566196 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7566196 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7566196 false true 24 174 42
Circle -7566196 false true 144 174 42
Circle -7566196 false true 234 174 42

turtle
true
0
Polygon -11352576 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -11352576 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -11352576 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -11352576 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -11352576 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7566196 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7566196 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7566196 true 150 285 150 15
Line -7566196 true 15 150 285 150
Circle -7566196 true true 120 120 60
Line -7566196 true 216 40 79 269
Line -7566196 true 40 84 269 221
Line -7566196 true 40 216 269 79
Line -7566196 true 84 40 221 269

x
false
0
Polygon -7566196 true true 270 75 225 30 30 225 75 270
Polygon -7566196 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 2.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
