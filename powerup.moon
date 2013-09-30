class Powerup

  name: 'powerup'
  specificName: 'powerup'

  new: (@world, @layer, @x, @y, @image) =>
    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addRect( -12, -12, 12, 12 )
    @fixture.character = @
    @fixture\setFilter(entityCategory.INACTIVEPOWERUP, entityCategory.BOUNDARY + entityCategory.INACTIVEPOWERUP + entityCategory.POWERUP)

    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture @image
    @texture\setRect -16, -16, 16, 16

    @prop = MOAIProp2D.new()
    @prop\setDeck @texture
    @prop.body = @body
    @prop.draggable = true
    @prop.isDragged = false
    @prop.isPowerup = true
    @prop.character = @
    @prop\setParent @body
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    @layer\insertProp @prop

  remove: () =>
    @layer\removeProp @prop

  destroy: () =>
    @world = nil
    @layer = nil
    @x = 0
    @y = 0
    @image = nil
    @body\destroy()
    @fixture\destroy()
    @prop = nil

  activate: () =>
    @fixture\setFilter(entityCategory.POWERUP, entityCategory.BOUNDARY + entityCategory.CHARACTER + entityCategory.POWERUP + entityCategory.INACTIVEPOWERUP)

class HealthPowerup extends Powerup

    specificName: 'health'

    execute: (character) =>
        character\alterHealth(5)

class ShieldPowerup extends Powerup

    specificName: 'shield'

    execute: (character) =>
      if character.stats.shield
        character.stats.shield += 1
      else
        character.stats.shield = 1

class PowerUpManager

  layer = nil
  world = nil

  powerups = {}

  getAmountOfPowerups: () ->
    return #powerups

  selectPowerups: (queryFunction) ->
    _.select(powerups, queryFunction)

  removePowerups: (queryFunction) ->
    powerups = _.reject(powerups, queryFunction)

  setLayerAndWorld: (newLayer, newWorld) ->
    layer = newLayer
    world = newWorld

  makePowerup: (powerupID, x, y) ->
    print powerupID
    powerupID = powerupID\lower()
    print "Powerup Factory: " .. powerupID
    newPowerup = {}

    switch powerupID
      when "health"
        newPowerup = HealthPowerup(world, layer, x, y, R.ASSETS.IMAGES[powerupID\upper!])

      when "shield"
        newPowerup = ShieldPowerup(world, layer, x, y, R.ASSETS.IMAGES[powerupID\upper!])

      else
        print "Generic Powerup"
        newPowerup = Powerup(world, layer, x, y, R.ASSETS.IMAGES[HEALTH])

    table.insert(powerups, newPowerup)
    return newPowerup

  getGraphic: (powerupID) ->
    return R.ASSETS.IMAGES[powerupID\upper!]

export powerupManager = PowerUpManager()