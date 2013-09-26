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
    print "Health was #{@stats.health}"
    @stats.health += deltaHealth
    print "Health is #{@stats.health}"
    if deltaHealth < 0
      @colorBlink(1.0, 0.0, 0.0)

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
      other\remove()
      other\destroy()
      other\execute(own)
      own\colorBlink(0.0, 1.0, 0.0)

class Hero extends PowerupUser

  name: 'hero'

  alterHealth: (deltaHealth) =>
    updateHealthBar(@stats.health)
    super deltaHealth

class Unit extends PowerupUser

  name: 'unit'

  beforeDeath: () =>
    x, y = @getLocation()
    powerupManager.makePowerup("health", x + 20 , y + 150 , R.MUSROOM)

class UFO extends Character

  name: 'ufo'

  onCollide: (own, other, event) =>
    own = own.character
    other = other.character
    if other.name == 'powerup'
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
  powerupInfobox =  nil

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

    powerupInfobox\setText("x " .. collectedPowerups[powerupSpecificName])
    
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
    powerupInfobox = PowerupInfobox(R.MUSHROOM, Rectangle(-10,-10, 10, 10), "x 0", Rectangle(0, 0, 50, 25), R.STYLE, LayerMgr\getLayer("ui"), 170, 130)

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
          health: 100,
          attack: 8,
          defense: 7
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Hero(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs, 0, -55)

      when "unit"
        print "Basic Unit Character"
        rectangle = Rectangle(-20,-20,20,20)

        stats = {
          health: 10,
          attack: 8,
          defense: 7
        }

        actionIDs = {
          "jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -70)

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
          health: 100,
          attack: 8,
          defense: 7
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Character(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs)
    table.insert(characters, newCharacter)
    return newCharacter


export characterManager = CharacterManager()
