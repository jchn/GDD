export class Healthbar

  new: (@layer, @width, @height, x = -200, y = -140) =>
    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture R.ASSETS.IMAGES.GREEN
    @texture\setRect 0, 0, @width, @height

    @healthBar = MOAIProp2D.new()
    @healthBar\setDeck @texture
    @healthBar\setLoc(x, y)
    @healthBar\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @layer\insertProp(@healthBar)

  update: (percentage) =>
    print "Updating healthbar. Percentage is #{percentage}"
    if percentage < 0
      percentage = 0
    elseif percentage > 1
      percentage = 1

    if percentage <= 0.34
      @texture\setTexture R.ASSETS.IMAGES.RED
      @healthBar\setDeck @texture
    elseif percentage <= 0.5
      @texture\setTexture R.ASSETS.IMAGES.YELLOW
      @healthBar\setDeck @texture
    else
      @texture\setTexture R.ASSETS.IMAGES.GREEN
      @healthBar\setDeck @texture

    width = percentage * @width
    print "Updating healthbar. Percentage is #{width}"
    @texture\setRect 0, 0, width, @height

  setLoc: (x, y) =>
    @healthBar\setLoc(x, y)

  destroy: () =>
    @layer\removeProp(@healthBar)
    @texture = nil
    @layer = nil
    @width = nil
    @height = nil