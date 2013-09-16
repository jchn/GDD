export class Rectangle
  new: (@xMin, @yMin, @xMax, @yMax) =>

  get: =>
    return @xMin, @yMin, @xMax, @yMax