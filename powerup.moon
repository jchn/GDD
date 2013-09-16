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