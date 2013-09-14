export class Character

  new: (@prop, @health, @behaviour, @layer) =>

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

  add: =>
    @layer\insertProp @prop
    @

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

  new: (@world, @layer, @x, @y, @image) =>
    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addRect( -10, -10, 10, 10 )

    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture @image
    @texture\setRect -10, -10, 10, 10

    @sprite = MOAIProp2D.new()
    @sprite\setDeck @texture
    @sprite.body = @body
    @sprite\setParent @body

    @layer\insertProp @sprite

export class AI

export class Pointer
  @pick: nil
  @mouseBody: nil
  @mouseJoint: nil
  @world
  @worldX: 0
  @worldY: 0

  new: (@world, @layer) =>
    -- TODO dit implementeren voor touch
    MOAIInputMgr.device.pointer\setCallback ( @\callback )
    MOAIInputMgr.device.mouseLeft\setCallback ( @\onClick )

  onClick: (down) =>
    if down
      @pick = @layer\getPartition()\propForPoint @worldX, @worldY
      print @pick
      if @pick
        @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC

        @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, @worldX, @worldY, 10000.0 * @pick.body\getMass()
    else
      if @pick
        @mouseBody\destroy()
        @mouseBody = nil
        @pick = nil

  callback: (x, y) =>
    print 'move'
    print @
    @worldX, @worldY = @layer\wndToWorld x, y

    if @pick
      @mouseJoint\setTarget @worldX, @worldY
