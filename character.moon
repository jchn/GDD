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

    if @init
      @init()

  getLocation: () =>
    return @body\getPosition()

  alterHealth: (deltaHealth) =>
    print "Health was #{@stats.health}"
    @stats.health += deltaHealth
    print "Health is #{@stats.health}"

  forceDeath: () =>
    @stats.health = 0

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
    if other.character.name == 'powerup'
      other.character\remove()
      other.character\destroy()
      p\clear()
      other.character\execute(own.character)

class Hero extends PowerupUser

  name: 'hero'

class Unit extends PowerupUser

  name: 'unit'

  beforeDeath: () =>
    x, y = @getLocation()
    powerupManager.makePowerup("health", x + 20 , y + 150 , R.MUSROOM)

class UFO extends Character

  name: 'ufo'

  init: () =>
    @powerupCollection = {}

  onCollide: (own, other, event) =>
    if other.character.name == 'powerup'
      other.character\remove()
      other.character\destroy()
      own.character\alterPowerups(other.character.specificName)
      p\clear()

  alterPowerups: (powerupSpecificName) =>
    if not @powerupCollection[powerupSpecificName]
      @powerupCollection[powerupSpecificName] = 0

    @powerupCollection[powerupSpecificName] += 1
    print "Powerup collection: #{@powerupCollection[powerupSpecificName]}"

class CharacterManager

  characters = {}
  layer = nil
  world = nil
  ufo = nil

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
