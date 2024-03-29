export class Rectangle
  new: (@xMin, @yMin, @xMax, @yMax) =>

  get: =>
    return @xMin, @yMin, @xMax, @yMax

  subtract: (xMin, yMin, xMax, yMax) =>
    @xMin -= xMin
    @yMin -= yMin
    @xMax -= xMax
    @yMax -= yMax
    @get()

  add: (xMin, yMin, xMax, yMax) =>
    @xMin += xMin
    @yMin += yMin
    @xMax += xMax
    @yMax += yMax
    @get()

  getWidth: () =>
    @yMax - @yMin

  setWidth: (width) =>
    

  getWidth: () =>
    math.abs(@xMin) + math.abs(@xMax)

  getHeight: () =>
    math.abs(@yMin) + math.abs(@yMax)
