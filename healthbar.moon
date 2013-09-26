export class Healthbar

  new: (@layer, @dimensions = Rectangle(0, 0, 100, 10), @x = -200, @y = -140) =>
    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture R.GREEN
    @texture\setRect @dimensions\get!

    @maxWidth = @dimensions\getWidth()

    healthBar = MOAIProp2D.new()
    healthBar\setDeck @texture
    healthBar\setLoc(@x, @y)
    healthBar\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @layer\insertProp(healthBar)

  update: (percentage) =>
    if percentage < 0
      percentage = 0

    width = (percentage/100) * @maxWidth
    @texture\setRect 0, 0, width, 10