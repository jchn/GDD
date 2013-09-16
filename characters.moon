export class Character

  new: (@prop, @health, @layer, @world) =>
    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform 0, 0
    @fixture = @body\addRect( -128, -128, 128, 128 )
    @prop\setParent @body
    @prop.body = @body

    @behaviour = Behaviour @

  name: 'character'

  update: =>
    @behaviour\execute(@)
    @

  add: =>
    @layer\insertProp @prop
    @

  remove: =>
    @layer\removeProp @prop
    @

  setBehaviour: (behaviour) =>
    -- Finish current behaviour, set new behaviour
    @behaviour\stop()
    @behaviour = behaviour

export class Hero extends Character

export class Enemy extends Character

export class Ufo extends Character

export class Behaviour

  name: 'behaviour'
  RUNNING: 1,
  IDLE: 2
  state: IDLE

  new: (@character) =>

  execute: =>
    @state = @RUNNING

  stop: =>
    @state = @IDLE

export class RotateBehaviour extends Behaviour

  execute: (characters) =>
    super
    -- character.prop\moveRot 360, 3

export class WalkBehaviour extends Behaviour

  execute: () =>
    super
    @character.body\setLinearVelocity 50, 0

  stop: () =>
    super
    @character.body\setLinearVelocity 0, 0

export class Powerup

  name: 'powerup'

  new: (@world, @layer, @x, @y, @image) =>
    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addRect( -10, -10, 10, 10 )

    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture @image
    @texture\setRect -10, -10, 10, 10

    @prop = MOAIProp2D.new()
    @prop\setDeck @texture
    @prop.body = @body
    @prop.draggable = true
    @prop\setParent @body

    @layer\insertProp @prop

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
      @mouseBody = @world\addBody MOAIBox2DBody.DYNAMIC
      if @pick and @pick.draggable

        @mouseJoint = @world\addMouseJoint @mouseBody, @pick.body, @worldX, @worldY, 10000.0 * @pick.body\getMass()
    else
      if @pick
        @mouseBody\destroy()
        @mouseBody = nil
        @pick = nil

  callback: (x, y) =>
    @worldX, @worldY = @layer\wndToWorld x, y

    if @pick and @pick.draggable
      @mouseJoint\setTarget @worldX, @worldY
