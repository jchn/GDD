class Clickable
  new: (@prop, @layer) =>
    @prop.clickable = true
    @prop.parent = @

  triggerClick: () =>

class ButtonManager
  buttons = {}
  forcefullyDisabled = false

  clear: () ->
    buttons = {}
    forcefullyDisabled = false

  enableButtons: (force = false) ->
    if force
      forcefullyDisabled = false
    if not forcefullyDisabled
      for button in *buttons do
        button\enable()

  forcefullyDisableButtons: () ->
    for button in *buttons do
      button\disable()
    forcefullyDisabled = true

  registerButton: (button) ->
    table.insert(buttons, button)

export buttonManager = ButtonManager()

class Button extends Clickable

  new: (@prop, @layer, @onClick, @enableFunction) =>
    @clickable = true
    if @enableFunction
      if @enableFunction()
        @enable()
      else
        @disable()

    super @prop, @layer
    @

  triggerClick: () =>
    if @clickable
      @onClick!

  disable: () =>
    @prop\setColor 1, 1, 1, 0.5
    @clickable = false
    if @afterDisable
      @afterDisable()

  enable: () =>
    if @enableFunction
      if not @enableFunction()
        @disable!
        return
    @prop\setColor 1, 1, 1, 1
    @clickable = true
    if @afterEnable
      @afterEnable()

  add: () =>
    @layer\insertProp @prop

  remove: () =>
    @layer\removeProp @prop

export class SimpleButton extends Button
  new: (@layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction) =>
    @prop = MOAIProp2D.new()
    @prop\setLoc(@x, @y)
    @prop\setColor 1.0, 1.0, 1.0, 1.0
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @gfxQuad = MOAIGfxQuad2D.new()
    @gfxQuad\setTexture( @texture )
    @gfxQuad\setRect( @rectangle\get() )

    @prop\setDeck( @gfxQuad )

    super @prop, @layer, @onClick, @enableFunction
    @

export class ImageButton extends SimpleButton

  new: (@layer, @texture, @image, @rectangle, @x, @y, @onClick, @enableFunction) =>

    @backgroundImage = MOAIProp2D.new()
    @backgroundImage\setLoc(@x, @y)
    @backgroundImage\setColor 1.0, 1.0, 1.0, 1.0
    @backgroundImage\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @background = MOAIGfxQuad2D.new()
    @background\setTexture(@image)
    @background\setRect(@rectangle\get() )
    @backgroundImage\setDeck(@background)

    @backgroundImage.clickable = true
    @backgroundImage.parent = @

    super @layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction

  add: () =>
    super @
    @layer\insertProp @backgroundImage

  remove: () =>
    super @
    @layer\removeProp @backgroundImage

export class AnimatedCooldownButton extends Button

  new: (@layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction) =>
    @prop = MOAIProp2D.new()

    @tileLib = MOAITileDeck2D\new()
    @tileLib\setTexture(@texture)
    @tileLib\setSize(9, 1)
    @tileLib\setRect(@rectangle\get())

    @prop\setDeck @tileLib
    @prop\setLoc @x, @y

    @curve = MOAIAnimCurve.new()
    @curve\reserveKeys(9)

    @curve\setKey(1, 0.2, 1)
    @curve\setKey(2, 0.4, 2)
    @curve\setKey(3, 0.6, 3)
    @curve\setKey(4, 0.8, 4)
    @curve\setKey(5, 1.0, 5)
    @curve\setKey(6, 1.2, 6)
    @curve\setKey(7, 1.4, 7)
    @curve\setKey(8, 1.6, 8)
    @curve\setKey(9, 1.8, 9)

    @anim = MOAIAnim\new()
    @anim\reserveLinks(1)
    @anim\setLink(1, @curve, @prop, MOAIProp2D.ATTR_INDEX)
    @anim\setMode(MOAITimer.NORMAL)
    @anim\setSpan(1.8)
    @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, -> buttonManager.enableButtons(true) )

    @prop\setColor 1.0, 1.0, 1.0, 1.0
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    buttonManager.registerButton(@)
    super @prop, @layer, @onClick, @enableFunction
    @

  afterDisable: () =>
    if @enableFunction
      if @enableFunction()
        @anim\start()
        return
    @anim\apply(0)

  afterEnable: () =>
    if @enableFunction
      if @enableFunction()
        @anim\apply(1.8)

  triggerClick: () =>
    if @clickable
      @onClick!
      buttonManager.forcefullyDisableButtons()
      

-- export class CoolDownButton extends SimpleButton
--   new: (@layer, @texture, @rectangle, @x, @y, @cooldown, @onClick, @enableFunction) =>
--     buttonManager.registerButton(@)
--     super @layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction     

--   triggerClick: () =>
--     -- Start cooldown
--     if @clickable
--       @onClick!
--       buttonManager.forcefullyDisableButtons()
--       performWithDelay(@cooldown, ->
--         buttonManager.enableButtons(true))