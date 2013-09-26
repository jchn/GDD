export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

class Character

  name: 'character'

  new: (@characterID, @prop, @layer, @world, @direction, @rectangle, @stats, actionIDs, x = 0, y = 0) =>
    @state = Characterstate.IDLE

    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform x, y
    @fixture = @body\addRect( @rectangle\get() )
    @fixture.character = @
    if @onCollide
      @fixture\setCollisionHandler(@onCollide, MOAIBox2DArbiter.BEGIN)
    @prop\setParent @body
    @prop.body = @body

    @actions = {}
    for actionID in *actionIDs do
      @addAction(actionID)

    @add()
    @update()

  getLocation: () =>
    return @body\getPosition()

  alterHealth: (deltaHealth) =>
    if deltaHealth < 0
      if @stats.shield
        if @stats.shield > 0
          @stats.shield -= 1
          return
      @colorBlink(1.0, 0.0, 0.0)
    print "Health was #{@stats.health}"
    @stats.health += deltaHealth
    print "Health is #{@stats.health}"
    if @healthbar
      @healthbar\update(@stats.health)

  setHealthbar: (healthbar) =>
    @healthbar = healthbar
    @

  forceDeath: () =>
    @stats.health = 0

  colorBlink: (red, green, blue, length = 0.40) =>
    @prop\seekColor red, green, blue, 1.0, 0.10
    @prop\moveColor 1.0, 1.0, 1.0, 1.0, length

  die: =>
    print "character died"
    if @beforeDeath
      @beforeDeath()
    characterManager.removeCharacters((c) -> return c == @)
    @remove()
    @destroy()

  addAction: (actionID) =>
    if @actions[actionID] == nil
      @actions[actionID] = actionManager.makeAction(actionID, @)
      print "added Action"
      print @actions[actionID]

  update: () =>
    if @stats.health > 0 and @state == Characterstate.IDLE
      doSomething, currentAction = ai.think(@)
      if doSomething
        currentAction\execute()
    elseif @stats.health <= 0
      @die()

  add: =>
    @layer\insertProp @prop
    @

  remove: =>
    print "REMOVED CHARACTER"
    @layer\removeProp @prop
    @

  destroy: =>
    print "DESTROY CHARACTER"
    @state = nil
    @prop = nil
    @fixture\destroy()
    @actions = nil
    @stats = nil
    @rectangle = nil
    @layer = nil
    @world = nil
    @direction = nil
    @body\destroy()

class PowerupUser extends Character

  onCollide: (own, other) =>
    own = own.character
    other = other.character
    if other.name == 'powerup'
      if other.prop.isDragged
        Pntr\clear()
      other\remove()
      other\destroy()
      other\execute(own)
      print "CHECK IF POWERUP IS BEING DRAGGED #{other.isDragged}"
      own\colorBlink(0.0, 1.0, 0.0)

class Hero extends PowerupUser

  name: 'hero'

  alterHealth: (deltaHealth) =>
    super deltaHealth

class Unit extends PowerupUser

  name: 'unit'

  setPowerupDrops: (@minDrops, @maxDrops, @possibleDrops) =>


  beforeDeath: () =>
    if not @minDrops
      @minDrops = 1

    if not @maxDrops
      @maxDrops = 1

    if not @possibleDrops
      @possibleDrops = { "health" }

    x, y = @getLocation()
    print "Drops between #{@minDrops}  and #{@maxDrops} items"
    drops = math.random(@minDrops, @maxDrops)

    for i  = 1, drops do
      dropping = math.random(#@possibleDrops)
      powerupManager.makePowerup(@possibleDrops[dropping], x + 20 , y + 150 , R.MUSROOM)

    --powerupManager.makePowerup("health", x + 20 , y + 150 , R.MUSROOM)

class UFO extends Character

  name: 'ufo'

  onCollide: (own, other, event) =>
    own = own.character
    other = other.character
    if other.name == 'powerup'
      if other.prop.isDragged
        Pntr\clear()
      other\remove()
      other\destroy()
      own\colorBlink(0.0, 1.0, 0.0, 1.00)
      characterManager.collectPowerup(other.specificName)
      

class CharacterManager

  characters = {}
  layer = nil
  world = nil
  ufo = nil

  collectedPowerups = {}
  lastTimestamp = 0
  comboCounter = 0
  powerupInfoboxes =  {}

  updatePowerupCounters: () ->
    x, y = 170, 130
    offsetX, offsetY = -90, 0

    for powerupInfobox in *powerupInfoboxes do
      powerupInfobox\remove()

    for powerUpID, amount in pairs collectedPowerups do
      graphic = powerupManager.getGraphic(powerUpID)
      print "USING THE GRAPHIC : #{graphic}"
      powerupInfobox = PowerupInfobox(graphic, Rectangle(-10, -10, 10, 10), "x #{amount}", Rectangle(0, 0, 60, 25), R.STYLE, LayerMgr\getLayer("ui"), x, y)
      x += offsetX
      y += offsetY
      table.insert(powerupInfoboxes, powerupInfobox)

  checkEnemySpawnable: (characterID) ->
    characterID = characterID\lower()
    switch characterID
      when "jumpwalker"
        return true
      when "elite_jumpwalker"
        if collectedPowerups["health"]
          if collectedPowerups["health"] >= 1
            return true
        return false
      when "supreme_jumpwalker"
        if collectedPowerups["shield"]
          if collectedPowerups["shield"] >= 4
            return true
        return false

  updatePowerupCounters: () ->
    x, y = 170, 130
    offsetX, offsetY = -90, 0

    for powerupInfobox in *powerupInfoboxes do
      powerupInfobox\remove()

    for powerUpID, amount in pairs collectedPowerups do
      graphic = powerupManager.getGraphic(powerUpID)
      print "USING THE GRAPHIC : #{powerUpID} and #{amount}"
      powerupInfobox = PowerupInfobox(graphic, Rectangle(-10, -10, 10, 10), "x #{amount}", Rectangle(0, 0, 60, 25), R.STYLE, LayerMgr\getLayer("ui"), x, y)
      x += offsetX
      y += offsetY
      table.insert(powerupInfoboxes, powerupInfobox)

  collectPowerup: (powerupSpecificName) ->
    if collectedPowerups[powerupSpecificName] == nil
      collectedPowerups[powerupSpecificName] = 0

    aantal = 1
    time = os.time()
    if time - lastTimestamp <= 1
      comboCounter += 1
      aantal = 1 + comboCounter
    else
      comboCounter = 0

    lastTimestamp = time

    collectedPowerups[powerupSpecificName] += aantal
    characterManager.updatePowerupCounters()
    print "Powerup collection: #{collectedPowerups[powerupSpecificName]} with combo counter #{comboCounter}"

  getSpawnableUnits: () ->
    -- foo

  selectCharacters: (queryFunction) ->
    _.select(characters, queryFunction)

  removeCharacters: (queryFunction) ->
    characters = _.reject(characters, queryFunction)

  setLayerAndWorld: (newLayer, newWorld) ->
    layer = newLayer
    world = newWorld

  makeCharacter: (characterID) ->
    characterID = characterID\lower()
    print "Character Factory: " .. characterID
    prop = MOAIProp2D.new()
    prop\setLoc(0, 0)
    prop\setColor 1.0, 1.0, 1.0, 1.0
    prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    newCharacter = {}

    switch characterID

      when "hero"
        print "Hero Character"
        rectangle = Rectangle(-32,-32,32,32)

        stats = {
          health: 100
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Hero(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs, 0, -55)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("ui")))

      when "jumpwalker"
        print "Basic Unit Character"
        rectangle = Rectangle(-20,-20,20,20)

        stats = {
          health: 10,
          attack: 1
        }

        actionIDs = {
          "jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -70)

      when "elite_jumpwalker"

        if collectedPowerups["health"]
          if collectedPowerups["health"] >= 1
            collectedPowerups["health"] -= 1
            characterManager.updatePowerupCounters()
          else
            return
        else
          return

        print "Shielded Unit Character"
        rectangle = Rectangle(-20,-20,20,20)

        stats = {
          health: 10,
          attack: 1,
          shield: 3
        }

        actionIDs = {
          "elite_jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -70)
        newCharacter\setPowerupDrops(1, 2, { "health", "shield" })

      when "supreme_jumpwalker"
  
        if collectedPowerups["shield"]
          if collectedPowerups["shield"] >= 4
            collectedPowerups["shield"] -= 4
            characterManager.updatePowerupCounters()
          else
            return
        else
          return

        print "Supreme Unit Character"
        rectangle = Rectangle(-20,-20,20,20)
        stats = {
          health: 10,
          attack: 10
        }

        actionIDs = {
          "supreme_jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -70)
        newCharacter\setPowerupDrops(0, 0, {})

      when "ufo"
        print "UFO Character"
        rectangle = Rectangle(-60,-50,60,50)

        stats = {
          health: 100
        }

        actionIDs= {
          "fly"
        }

        newCharacter = UFO(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs, 0, 20)
        ufo = newCharacter

      else
        print "Generic Character"
        rectangle = Rectangle(-32,-32,32,32)

        stats = {
          health: 100
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Character(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs)
    table.insert(characters, newCharacter)
    newCharacter\add()
    return newCharacter

export characterManager = CharacterManager()
