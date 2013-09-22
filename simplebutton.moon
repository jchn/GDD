class Clickable
  new: (@prop, @layer) =>
    @prop.clickable = true
    @prop.parent = @

  onClick: () =>

export class SimpleButton extends Clickable
  new: (@layer, @texture, @rectangle, @onClick = ->) =>
    @prop = MOAIProp2D.new()
    @prop\setLoc(0, 0)
    @prop\setColor 1.0, 1.0, 1.0, 1.0
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @gfxQuad = MOAIGfxQuad2D.new()
    @gfxQuad\setTexture( @texture )
    @gfxQuad\setRect( @rectangle\get() )

    @prop\setDeck( @gfxQuad )

    super @prop, @layer
    ''

  add: () =>
    @layer\insertProp @prop

  remove: () =>
    @layer\removeProp @prop
