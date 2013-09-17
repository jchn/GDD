export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

class Character
  new: (@prop, @layer, @world, @direction, @rectangle, @stats = { health: 100 }, @behaviors = {}) =>
    @state = Characterstate.IDLE

    @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
    @body\setTransform -200, -55
    @fixture = @body\addRect( @rectangle\get() )
    @prop\setParent @body
    @prop.body = @body

    @behavior = Action()

  alterHealth: (deltaHealth) =>
    @stats.health += deltaHealth
    if @stats.health <= 0
      @die()

  die: =>
    print "Character dead"

  addBehavior: (behavior) =>
    -- print "addBehavior "..behaviorID\lower()
    -- table.insert @behaviors, behaviorID\lower()

    @behavior\stop(@)
    @behavior = behavior

  update: =>
    @behavior\execute(@)

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

class Hero extends Character

class BasicUnit extends Character

class UFO extends Character

class CharacterFactory
  makeCharacter: (characterID, layer, world, direction, stats = { health: 100 }, behaviors = {}) ->
    characterID = characterID\lower()
    print "Factory: " .. characterID
    prop = MOAIProp2D.new()
    prop\setLoc(0, 0)
    prop\setColor 1.0, 1.0, 1.0, 1.0
    prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    switch characterID
      when "hero"
        print "Hero Character"
        rectangle = Rectangle(-32,-32,32,32)
        Hero(prop, layer, world, direction, rectangle, stats, behaviors)

      when "unit"
        print "Basic Unit Character"
        rectangle = Rectangle(-32,-32,32,32)
        Hero(prop, layer, world, direction, rectangle, stats, behaviors)

      else
        print "Generic Unit Character"
        rectangle = Rectangle(-32,-32,32,32)
        Character(prop, layer, world, direction, rectangle, stats, behaviors)


export characterFactory = CharacterFactory()