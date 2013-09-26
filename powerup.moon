class Powerup

  name: 'powerup'
  specificName: 'powerup'

  new: (@world, @layer, @x, @y, @image) =>
    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addRect( -12, -12, 12, 12 )
    @fixture.character = @

    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture @image
    @texture\setRect -16, -16, 16, 16

    @prop = MOAIProp2D.new()
    @prop\setDeck @texture
    @prop.body = @body
    @prop.draggable = true
    @prop.isDragged = false
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

  setLayerAndWorld: (newLayer, newWorld) ->
    layer = newLayer
    world = newWorld

  makePowerup: (powerupID, x, y) ->
    powerupID = powerupID\lower()
    print "Powerup Factory: " .. powerupID
    newPowerup = {}

    switch powerupID
      when "health"
        newPowerup = HealthPowerup(world, layer, x, y, powerupManager.getGraphic(powerupID))

      when "shield"
        newPowerup = ShieldPowerup(world, layer, x, y, powerupManager.getGraphic(powerupID))

      else
        print "Generic Powerup"
        newPowerup = Powerup(world, layer, x, y, R.MUSHROOM)

    return newPowerup

  getGraphic: (powerupID) ->
    powerupID = powerupID\lower()

    switch powerupID
      when "health"
        return R.MUSHROOM

      when "shield"
        return R.MUSHROOM2


export powerupManager = PowerUpManager()