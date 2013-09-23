class Powerup

  name: 'powerup'
  specificName: 'powerup'

  new: (@world, @layer, @x, @y, @image) =>
    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addRect( -10, -10, 10, 10 )
    @fixture.character = @

    @texture = MOAIGfxQuad2D.new()
    @texture\setTexture @image
    @texture\setRect -10, -10, 10, 10

    @prop = MOAIProp2D.new()
    @prop\setDeck @texture
    @prop.body = @body
    @prop.draggable = true
    @prop\setParent @body

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

    specificName: 'health_powerup'

    execute: (character) =>
        character\alterHealth(5)

class ShieldPowerup extends Powerup

    specificName: 'shield_powerup'

    execute: (character) =>
        print "Defense was #{character.stats.defense}"
        character.stats.defense += 5
        print "Defense is #{character.stats.defense}"

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
        newPowerup = HealthPowerup(world, layer, x, y, R.MUSHROOM)

      when "shield"
        newPowerup = ShieldPowerup(world, layer, x, y, R.MUSHROOM)

      else
        print "Generic Powerup"
        newPowerup = Powerup(world, layer, x, y, R.MUSHROOM)

    return newPowerup


export powerupManager = PowerUpManager()