class Clickable
  new: (@prop, @layer) =>
    @prop.clickable = true
    @prop.parent = @

  triggerClick: () =>

export class SimpleButton extends Clickable
  new: (@layer, @texture, @rectangle, @x, @y, @onClick = ->) =>
    @prop = MOAIProp2D.new()
    @prop\setLoc(@x, @y)
    @prop\setColor 1.0, 1.0, 1.0, 1.0
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    @clickable = true

    -- @rectangle\wndToWorld!

    @gfxQuad = MOAIGfxQuad2D.new()
    @gfxQuad\setTexture( @texture )
    @gfxQuad\setRect( @rectangle\get() )

    @prop\setDeck( @gfxQuad )

    super @prop, @layer

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
    @prop\setColor 1, 1, 1, 1
    @clickable = true

export class CoolDownButton extends SimpleButton
  new: (@layer, @texture, @rectangle, @x, @y, @cooldown, @onClick = ->) =>
    super @layer, @texture, @rectangle, @x, @y, @onClick
    @clickable = true
    print "cooldown: #{cooldown}"    

  triggerClick: () =>
    -- Start cooldown
    if @clickable
      @onClick!
      @disable!
      performWithDelay(@cooldown, @\enable)


