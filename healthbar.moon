export class Healthbar

  new: (@layer, @width, @height, x = -220, y = 110) =>
    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture R.ASSETS.IMAGES.GREEN
    @texture\setRect 0, 0, @width, @height

    backgroundTexture = MOAIGfxQuad2D.new()
    backgroundTexture\setTexture R.ASSETS.IMAGES.BLACK
    backgroundTexture\setRect 0, 0, @width, @height

    @background = MOAIProp2D.new()
    @background\setDeck backgroundTexture
    @background\setLoc(x, y)
    @background\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    @background\setColor 1, 1, 1, 0.6

    @healthBar = MOAIProp2D.new()
    @healthBar\setDeck @texture
    @healthBar\setLoc(x, y)
    @healthBar\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @layer\insertProp(@background)
    @layer\insertProp(@healthBar)

  update: (percentage) =>
    print "Updating healthbar. Percentage is #{percentage}"
    if percentage < 0
      percentage = 0
    elseif percentage > 1
      percentage = 1

    if percentage <= 0.33
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
    @background\setLoc(x, y)
    @healthBar\setLoc(x, y)

  setVisible: (bool) =>
    @background\setVisible(bool)
    @healthBar\setVisible(bool)

  destroy: () =>
    @layer\removeProp(@background)
    @layer\removeProp(@healthBar)
    @texture = nil
    @layer = nil
    @width = nil
    @height = nil