class Powerup

  name: 'powerup'
  specificName: 'powerup'

  new: (@world, @layer, @x, @y, @image) =>

    @body = @world\addBody( MOAIBox2DBody.DYNAMIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addCircle( 0, 0, 16)
    @fixture.parent = @
    @fixture\setFilter(entityCategory.INACTIVEPOWERUP, entityCategory.BOUNDARY + entityCategory.INACTIVEPOWERUP + entityCategory.POWERUP + entityCategory.CHARACTER)

    @prop = MOAIProp2D.new()
    @prop.body = @body
    @prop.draggable = true
    @prop.isDragged = false
    @prop.isPowerup = true
    @prop.parent = @
    @prop\setParent @body
    -- @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    rect = Rectangle(-32,-32,32,32)

    @tileLib = MOAITileDeck2D\new()
    @tileLib\setTexture(@image)
    @tileLib\setSize(2, 1)
    @tileLib\setRect(rect\get())

    @prop\setDeck @tileLib

    @curve = MOAIAnimCurve.new()
    @curve\reserveKeys(2)

    @curve\setKey(1, 0.25, 1)
    @curve\setKey(2, 0.5, 2)

    @anim = MOAIAnim\new()
    @anim\reserveLinks(1)
    @anim\setLink(1, @curve, @prop, MOAIProp2D.ATTR_INDEX)
    @anim\setMode(MOAITimer.LOOP)
    @anim\setSpan(1)
    @anim\start()

    @layer\insertProp @prop
    @active = false

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
    print "Activating powerup. @active is: #{@active}"
    if @active == false
      print "NOW THE POWERUP SHALL BE ACTIVATED. AND IT SHALL BE GLORIOUS!"
      @active = true
      @fixture\setFilter(entityCategory.POWERUP, entityCategory.BOUNDARY + entityCategory.CHARACTER + entityCategory.POWERUP + entityCategory.INACTIVEPOWERUP + entityCategory.DRAGGEDPOWERUP)

  beginDrag: () =>
    @active = true
    @fixture\setFilter(entityCategory.DRAGGEDPOWERUP, entityCategory.BOUNDARY + entityCategory.CHARACTER + entityCategory.POWERUP + entityCategory.INACTIVEPOWERUP)

  endDrag: () =>
    @active = false
    @activate()

class HealthPowerup extends Powerup

  specificName: 'health'

  execute: (character) =>
      character\alterHealth(character.powerupStats.health)

class ShieldPowerup extends Powerup

  specificName: 'shield'

  execute: (character) =>
    if character.stats.shield
      character.stats.shield += character.powerupStats.shield
    else
      character.stats.shield = character.powerupStats.shield

    if character.icon == nil
      character.icon = powerupManager.makePowerupIcon("shield")

class StrengthPowerup extends Powerup

  specificName: 'strength'

  execute: (character) =>
    character.stats.attack += character.powerupStats.strength

class Bullet

  name: 'bullet'

  new: (@world, @layer, @x, @y, @image) =>

    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform(@x, @y)

    @fixture = @body\addCircle( 0, 0, 16)
    @fixture.parent = @
    @fixture\setFilter(entityCategory.BULLET, entityCategory.BOUNDARY + entityCategory.CHARACTER)

    @prop = MOAIProp2D.new()
    @prop.body = @body
    @prop.isPowerup = true
    @prop.parent = @
    @prop\setParent @body
    @prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    rect = Rectangle(-32,-32,32,32)

    @tileLib = MOAITileDeck2D\new()
    @tileLib\setTexture(@image)
    @tileLib\setSize(2, 1)
    @tileLib\setRect(rect\get())

    @prop\setDeck @tileLib

    @curve = MOAIAnimCurve.new()
    @curve\reserveKeys(2)

    @curve\setKey(1, 0.25, 1)
    @curve\setKey(2, 0.5, 2)

    @anim = MOAIAnim\new()
    @anim\reserveLinks(1)
    @anim\setLink(1, @curve, @prop, MOAIProp2D.ATTR_INDEX)
    @anim\setMode(MOAITimer.LOOP)
    @anim\setSpan(1)
    @anim\start()

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

  execute: (character) =>
    character\alterHealth(-1, true)

class PowerUpManager

  layer = nil
  world = nil

  powerups = {}

  removeAndDestroyAllPowerups: () ->
    for powerup in *powerups do
      powerup\remove!
      powerup\destroy!
    powerups = {}

  makePowerupIcon: (powerupID) ->
    texture = MOAIGfxQuad2D.new()
    texture\setTexture R.ASSETS.IMAGES["#{powerupID}_ICON"\upper!]
    texture\setRect -10, -10, 10, 10

    prop = MOAIProp2D.new()
    prop\setDeck texture
    prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
    LayerMgr\getLayer('characters')\insertProp(prop)
    return prop

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
        newPowerup = HealthPowerup(world, layer, x, y, R.ASSETS.IMAGES["#{powerupID}_ANIM"\upper!])

      when "shield"
        newPowerup = ShieldPowerup(world, layer, x, y, R.ASSETS.IMAGES["#{powerupID}_ANIM"\upper!])

      when "strength"
        newPowerup = StrengthPowerup(world, layer, x, y, R.ASSETS.IMAGES["#{powerupID}_ANIM"\upper!])

      when "bullet"
        newPowerup = Bullet(world, layer, x, y, R.ASSETS.IMAGES.STRENGTH_ANIM)

      else
        print "Generic Powerup"
        newPowerup = Powerup(world, layer, x, y, R.ASSETS.IMAGES.HEALTH)

    table.insert(powerups, newPowerup)
    return newPowerup

  getGraphic: (powerupID) ->
    return R.ASSETS.IMAGES[powerupID\upper!]

export powerupManager = PowerUpManager()