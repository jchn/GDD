export class Indicator
  new: (@startX, @length, @layer, @x, @y, @onEndReached = ->) =>
    -- @x, @y = @layer\worldToWnd @x, @y
    @propBase = MOAIProp2D.new()
    @propBase\setLoc @x, @y
    @propIndicator = MOAIProp2D.new()
    @propIndicator\setLoc @x, @y

    rectBase = Rectangle -64, -16, 64, 16
    @quadBase = MOAIGfxQuad2D.new()
    @quadBase\setTexture( R.ASSETS.TEXTURES.INDICATOR_BASE )
    @quadBase\setRect( rectBase\get() )
    @quadBase\setUVRect rectBase\get!
    @propBase\setDeck @quadBase

    rectIndicator = Rectangle -4, -8, 4, 8
    @quadIndicator = MOAIGfxQuad2D.new()
    @quadIndicator\setTexture( R.ASSETS.TEXTURES.INDICATOR )
    @quadIndicator\setRect rectIndicator\get()
    @quadIndicator\setRect rectIndicator\get!
    @propIndicator\setDeck @quadIndicator

    @width = rectBase\getWidth!

    @indicatorStartX, @indicatorStartY = @propIndicator\getLoc!
    @indicatorStartX -= @width/2
    @propIndicator\setLoc @indicatorStartX, @indicatorStartY

  add: () =>
    @layer\insertProp @propBase
    @layer\insertProp @propIndicator

  remove: () =>
    @layer\removeProp @propBase
    @layer\removeProp @propIndicator

  update: (currentX) =>
    diff = currentX - @startX
    progress = diff/@length
    offset = @width * progress
    offset -= @width / 2

    if progress > 1
      @onEndReached!
    else
      @propIndicator\setLoc offset, @indicatorStartY
