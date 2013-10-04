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

export class SimpleButton extends Clickable
  new: (@layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction) =>
    @prop = MOAIProp2D.new()
    @prop\setLoc(@x, @y)
    @prop\setColor 1.0, 1.0, 1.0, 1.0
    -- @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    @clickable = true

    -- @rectangle\wndToWorld!

    @gfxQuad = MOAIGfxQuad2D.new()
    @gfxQuad\setTexture( @texture )
    @gfxQuad\setRect( @rectangle\get() )

    @prop\setDeck( @gfxQuad )

    print "BUTTON MADE. #{@enableFunction}"

    if @enableFunction
      if @enableFunction()
        print "BUTTON IS ENABLED!"
        @enable()
      else
        print "BUTTON IS DISABLED!"
        @disable()

    super @prop, @layer
    @

  add: () =>
    @layer\insertProp @prop

  remove: () =>
    @layer\removeProp @prop

  triggerClick: () =>
    if @clickable
      @onClick!

  disable: () =>
    @prop\setColor 1, 1, 1, 0.5
    @clickable = false

  enable: () =>
    if @enableFunction
      if not @enableFunction()
        @disable!
        return
    @prop\setColor 1, 1, 1, 1
    @clickable = true

export class CoolDownButton extends SimpleButton
  new: (@layer, @texture, @rectangle, @x, @y, @cooldown, @onClick, @enableFunction) =>
    buttonManager.registerButton(@)
    super @layer, @texture, @rectangle, @x, @y, @onClick, @enableFunction     

  triggerClick: () =>
    -- Start cooldown
    if @clickable
      @onClick!
      buttonManager.forcefullyDisableButtons()
      performWithDelay(@cooldown, ->
        buttonManager.enableButtons(true))



