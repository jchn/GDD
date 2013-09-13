export class Character

  new: (@prop, @health, @behaviour, @layer) =>
    -- @layer\insertProp(@prop)
    -- @delegateClick()

  name: 'character'

  method: ->
    print "method"

  remove: =>
    @layer\removeProp(@prop)

  update: =>
    @behaviour\execute(@)

  delegateClick: =>
    if MOAIInputMgr.device.pointer
      MOAIInputMgr.device.mouseLeft\setCallback @onClick

  onClick: (down) ->
    if down
      print "you've clicked me, what's the matter mate?!"

  add: =>
    @layer\insertProp @prop

  remove: =>
    @layer\removeProp @prop




export class Hero extends Character

export class Enemy extends Character

export class Ufo extends Character

export class Behaviour

  new: =>

  execute: =>

export class RotateBehaviour extends Behaviour

  execute: (character) =>
    character.prop\moveRot 360, 3

export class Powerup

export class AI

export class Pointer
  mouseX: 0
  mouseY: 0

  update: (x, y) ->
    Pointer.mouseX = x
    Pointer.mouseY = y
