export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

class Character
  new: (@characterID, @prop, @layer, @world, @direction, @rectangle, @stats, actionIDs) =>
    @state = Characterstate.IDLE

    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform -200, -55
    @fixture = @body\addRect( @rectangle\get() )
    @prop\setParent @body
    @prop.body = @body

    --@behavior = Action(@)

    @actions = {}
    for actionID in *actionIDs do
      @addAction(actionID)

  getLocation: () =>
    return @body.getLocation()

  alterHealth: (deltaHealth) =>
    @stats.health += deltaHealth
    if @stats.health <= 0
      @die()

  die: =>
    print "Character dead"

  addAction: (actionID) =>
    if @actions[actionID] == nil
      @actions[actionID] = actionFactory.makeAction(actionID, @)
      print "added Action"
      print @actions[actionID]

  --addBehavior: (behavior) =>
    -- print "addBehavior "..behaviorID\lower()
    -- table.insert @behaviors, behaviorID\lower()

    --@behavior\stop()
    --print 'behavior in character'
    --print @behavior.character
    --@behavior = behavior

  update: =>
    if @state == Characterstate.IDLE
      doSomething, currentAction = ai.think(@)
      if doSomething
        currentAction\execute()

  add: =>
    @layer\insertProp @prop

    -- curve = MOAIAnimCurve.new()
    -- curve\reserveKeys(2)

    -- curve\setKey(1, 0.25, 1)
    -- curve\setKey(2, 0.5, 2)

    -- anim = MOAIAnim\new()
    -- anim\reserveLinks(1)
    -- anim\setLink(1, curve, @prop, MOAIProp2D.ATTR_INDEX)
    -- anim\setMode(MOAITimer.LOOP)
    -- anim\setSpan(1)
    -- anim\start()
    @

  remove: =>
    @layer\removeProp @prop
    @

  destroy: =>
    @state = nil
    @pop = nil
    @fixture = nil
    @actions = nil
    @stats = nil
    @rectangle = nil
    @layer = nil
    @world = nil
    @direction = nil
    @body\destroy()

class Hero extends Character

class Unit extends Character

class UFO extends Character

class CharacterManager

  characters = {}

  updateCharacters: () ->
    for character in *characters do
      character\update()

  selectCharacters: (queryFunction) ->
    selected = {}

    for char in *characters do
      if queryFunction(char)
        selected[#selected+1] = char
    return selected

  removeCharacters: (queryFunction) ->
    tempCharacters = {}

    for char in *characters do
      if not queryFunction(char)
        tempCharacters[#tempCharacters+1] = char
      else
        char\remove()
        char\destroy()

    characters = tempCharacters

  makeCharacter: (characterID, layer, world) ->
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

        newCharacter = Hero(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs)

      when "unit"
        print "Basic Unit Character"
        rectangle = Rectangle(-32,-32,32,32)

        stats = {
          health: 100,
          attack: 8,
          defense: 7
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs)

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
