export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

class Character

  name: 'character'

  new: (@characterID, @prop, @layer, @world, @direction, @rectangle, @stats, actionIDs, @x = 0, @y = 0, @powerupStats = { health: 1, shield: 1, strength: 1 }, makeDefaultBody = true) =>
    @state = Characterstate.IDLE
    @body = nil
    @fixture = nil

    if makeDefaultBody
      @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
      @body\setTransform @x, @y
      @fixture = @body\addRect( @rectangle\get() )
      @fixture.parent = @
      if @onCollide
        @fixture\setCollisionHandler(@onCollide, MOAIBox2DArbiter.BEGIN)
      @prop\setParent @body
      @prop.body = @body
    @currentAction = {}

    @stats.maxHealth = @stats.health

    @actions = {}
    for actionID in *actionIDs do
      @addAction(actionID)

    @add()
    @update()

  getHeight: () =>
    return @rectangle\getHeight()

  getWidth: () =>
    return @rectangle\getWidth()

  setFilter: (category, mask) =>
    @fixture\setFilter(category, mask)

  getLocation: () =>
    return @body\getPosition()

  showFloatingNumber: (text, length, style, offsetX = 0, offsetY = 0) =>
    x, y = @getLocation()
    print "Random x offset: #{randomOffset}"
    x += math.random(-offsetX, offsetX)
    y += math.random(-offsetY, offsetY)
    floatingNumber = FloatingNumber(text, Rectangle(0, 0, 100, 50), style, length, x, y)

    timer = MOAITimer.new()
    timer\setSpan(length)
    timer\setMode(MOAITimer.NORMAL)
    timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
      floatingNumber\destroy()
      floatingNumber = nil)
    timer\start()

  alterHealth: (deltaHealth) =>
    if deltaHealth < 0
      if @stats.shield
        if @stats.shield > 0
          @stats.shield -= 1

          if @stats.shield <= 0
            @layer\removeProp @icon
            @icon = nil
          return
      @colorBlink(1.0, 0.0, 0.0)
    print "Health was #{@stats.health}"
    @stats.health += deltaHealth

    if @stats.health > @stats.maxHealth
      @stats.maxHealth = @stats.health
    print "Health is #{@stats.health}"
    
    if @healthbar
      print "Health % is now: #{@stats.health / @stats.maxHealth}"
      @healthbar\update(@stats.health / @stats.maxHealth)
    if @stats.health <= 0
      @die()
      return true

  setHealthbar: (healthbar, fixedPosition = true) =>
    @healthbar = healthbar
    @healthbarFixedPosition = fixedPosition
    @

  forceDeath: () =>
    @stats.health = 0

  colorBlink: (red, green, blue, length = 0.40) =>
    @prop\seekColor red, green, blue, 1.0, 0.10
    @prop\moveColor 1.0, 1.0, 1.0, 1.0, length

  die: () =>
    @remove()
    @destroy()
    characterManager.removeCharacters((c) -> return c == @)

  addAction: (actionID) =>
    if @actions[actionID] == nil
      @actions[actionID] = actionManager.makeAction(actionID, @)
      print "added Action"
      print @actions[actionID]

  doAction: (actionID) =>
    @currentAction\beforeStop()
    @state = Characterstate.IDLE
    @currentAction = actionManager.makeAction(actionID, @)
    print "Doing action: #{@currentAction}"
    @currentAction\execute()

  update: () =>
    if @stats.health > 0 and @state == Characterstate.IDLE
      doSomething, @currentAction = ai.think(@)
      if doSomething
        @currentAction\execute()

  add: =>
    @layer\insertProp @prop
    @

  remove: =>
    @layer\removeProp @prop
    @

  removeIcon: () =>
    if @icon != nil
      @layer\removeProp @icon
      @icon = nil

  destroy: =>
    print "DESTROY CHARACTER"
    if @currentAction != nil and @state == Characterstate.EXECUTING
      @currentAction\beforeStop()
    if @healthbar != nil
      @healthbar\destroy!
      @healthbarFixedPosition = nil
    @removeIcon()
    @healthbar = nil
    @currentAction = nil
    @state = nil
    @prop = nil
    @fixture\destroy()
    @fixture = nil
    @actions = nil
    @stats = nil
    @rectangle = nil
    @layer = nil
    @world = nil
    @direction = nil
    @body\destroy()
    @body = nil
    @actions = nil

class PowerupUser extends Character

  onCollide: (own, other) =>
    own = own.parent
    other = other.parent
    if other.name == 'powerup'
      if other.prop.isDragged
        Pntr\clear()
      powerupManager.removePowerups((p) -> return p == other)
      other\remove()
      other\destroy()
      other\execute(own)
      print "CHECK IF POWERUP IS BEING DRAGGED #{other.isDragged}"
      own\colorBlink(0.0, 1.0, 0.0)
      

class Hero extends PowerupUser

  name: 'hero'

  alterHealth: (deltaHealth) =>
    super deltaHealth
    if deltaHealth >= 0
      @showFloatingNumber("+#{deltaHealth}", 2, R.GREENSTYLE)
    else
      @showFloatingNumber("#{deltaHealth}", 2, R.REDSTYLE)
      R.HIT\play!

  die: () =>
    

class Unit extends PowerupUser

  name: 'unit'

  setPowerupDrops: (@minDrops, @maxDrops, @possibleDrops) =>

  die: () =>
    x, y = @getLocation()
    super super
    if not @minDrops
      @minDrops = 1

    if not @maxDrops
      @maxDrops = 1

    if not @possibleDrops
      @possibleDrops = { "health" }

    
    print "Drops between #{@minDrops}  and #{@maxDrops} items"
    drops = math.random(@minDrops, @maxDrops)

    for i  = 1, drops do
      dropping = math.random(#@possibleDrops)

      powerup = powerupManager.makePowerup(@possibleDrops[dropping], (x - 10 + (i * 10)) , y)
      powerup.body\applyLinearImpulse(140,100)
      timer = MOAITimer.new()
      timer\setSpan(1)
      timer\setMode(MOAITimer.NORMAL)
      timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
        powerup\activate!)
      timer\start()

class UFO extends Character

  name: 'ufo'

  -- new: (@characterID, @prop, @layer, @world, @direction, @rectangle, @stats, actionIDs, @x = 0, @y = 0, @powerupStats = { health: 1, shield: 1, strength: 1 }) =>
  --   @state = Characterstate.IDLE

  --   @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
  --   @body\setTransform @x, @y
  --   polygon = {
  --     0, 45,
  --     10, 30,
  --     57, 0,
  --     52, -5
  --     -64, 0 
  --   }
  --   @fixture = @body\addPolygon( polygon )
  --   @fixture.character = @

  --   if @onCollide
  --     @fixture\setCollisionHandler(@onCollide, MOAIBox2DArbiter.BEGIN)

  --   @prop\setParent @body
  --   @prop.body = @body
  --   @currentAction = {}

  --   @stats.maxHealth = @stats.health

  --   @actions = {}
  --   for actionID in *actionIDs do
  --     @addAction(actionID)

  --   @add()
  --   @update()

  onCollide: (own, other, event) =>
    own = own.parent
    other = other.parent
    if other.name == 'powerup'
      if other.prop.isDragged
        Pntr\clear()
      other\remove()
      other\destroy()
      own\colorBlink(0.0, 1.0, 0.0, 1.00)
      amount = characterManager.collectPowerup(other.specificName)
      if amount >= 0
        own\showFloatingNumber("+#{amount}", 4, R.GREENSTYLE, 40, 20)
      else
        style = R.REDSTYLE
        own\showFloatingNumber("#{amount}", 4, R.REDSTYLE, 40, 20)
      powerupManager.removePowerups((p) -> return p == other)
      

class CharacterManager

  characters = {}
  layer = nil
  world = nil
  ufo = nil

  collectedPowerups = {}
  lastTimestamp = 0
  comboCounter = 0
  powerupInfoboxes =  {}

  updateCharacters: () ->
    for character in *characters do
      if character.icon != nil
        x, y = character\getLocation()
        y += (character\getHeight()/2 + 6)
        character.icon\setLoc x, y
        if character.healthbar != nil and character.healthbarFixedPosition == false
          character.healthbar\setVisible(false)
      elseif character.healthbar != nil and character.healthbarFixedPosition == false
        x, y = character\getLocation()
        y += (character\getHeight()/2)
        x -= (character\getWidth()/2)
        character.healthbar\setLoc(x, y)
        character.healthbar\setVisible(true)

  updatePowerupCounters: () ->
    x, y = 170, 130
    offsetX, offsetY = -90, 0

    for powerupInfobox in *powerupInfoboxes do
      powerupInfobox\remove()

    for powerUpID, amount in pairs collectedPowerups do
      graphic = powerupManager.getGraphic(powerUpID)
      print "USING THE GRAPHIC : #{graphic}"
      powerupInfobox = PowerupInfobox(graphic, Rectangle(-16, -16, 16, 16), "x #{amount}", Rectangle(0, 0, 60, 25), R.STYLE, LayerMgr\getLayer("ui"), x, y)
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
    offsetX, offsetY = -60, 0

    for powerupInfobox in *powerupInfoboxes do
      powerupInfobox\remove()

    for powerUpID, amount in pairs collectedPowerups do
      graphic = powerupManager.getGraphic(powerUpID)
      print "USING THE GRAPHIC : #{powerUpID} and #{amount}"
      powerupInfobox = PowerupInfobox(graphic, Rectangle(-10, -10, 10, 10), "#{amount}", Rectangle(0, 0, 30, 25), R.ASSETS.STYLES.ARIAL, LayerMgr\getLayer("ui"), x, y, powerUpID)
      x += offsetX
      y += offsetY
      table.insert(powerupInfoboxes, powerupInfobox)

  collectPowerup: (powerupSpecificName) ->
    if collectedPowerups[powerupSpecificName] == nil
      collectedPowerups[powerupSpecificName] = 0

    aantal = 1
    -- time = os.time()
    -- if time - lastTimestamp <= 1
    --   comboCounter += 1
    --   aantal = 1 + comboCounter
    -- else
    --   comboCounter = 0

    -- lastTimestamp = time

    if collectedPowerups[powerupSpecificName] >= 99
      aantal = 0

    collectedPowerups[powerupSpecificName] += aantal
    characterManager.updatePowerupCounters()
    print "Powerup collection: #{collectedPowerups[powerupSpecificName]} with combo counter #{comboCounter}"
    buttonManager.enableButtons()
    return aantal

  useCollectedPowerup: (powerupSpecificName) ->
    collectedPowerups[powerupSpecificName] -= 1
    characterManager.updatePowerupCounters()
    buttonManager.enableButtons()

  powerupInCollection: (powerupSpecificName) ->
    if collectedPowerups[powerupSpecificName] != nil
      return collectedPowerups[powerupSpecificName] >= 1
    return false

  getSpawnableUnits: () ->
    -- foo

  selectCharacters: (queryFunction) ->
    _.select(characters, queryFunction)

  removeCharacters: (queryFunction) ->
    characters = _.reject(characters, queryFunction)

  removeAndDestroyCharacters: (queryFunction) ->
    selectedCharacters = characterManager.selectCharacters(queryFunction)
    for character in *selectedCharacters do
      character\remove!
      character\destroy!
    characterManager.removeCharacters(queryFunction)

  setLayerAndWorld: (newLayer, newWorld) ->
    layer = newLayer
    world = newWorld

  clear: () ->
    for character in *characters do
      character\destroy()
    characters = {}
    ufo = nil
    collectedPowerups = {}
    lastTimestamp = 0
    comboCounter = 0
    powerupInfoboxes = {}

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
          speed: 40,
          attack: 5
        }

        powerupStats = {
          health: 5,
          shield: 1,
          strength: 5
        }

        actionIDs = {
          "walk", "run"
        }

        newCharacter = Hero(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs, 0, -35, powerupStats)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("ui"), 100, 10))
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.POWERUP + entityCategory.BOUNDARY)

      when "jumpwalker"
        print "Basic Unit Character"
        rectangle = Rectangle(-20,-20,20,20)

        stats = {
          health: 10,
          attack: 1,
          speed: 80
        }

        actionIDs = {
          "jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -50)
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.BOUNDARY)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("characters"), 40, 4), false)
        ufo\doAction("spawn")

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
          shield: 2,
          speed: 60
        }

        actionIDs = {
          "elite_jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -50)
        newCharacter\setPowerupDrops(1, 2, { "health", "shield", "shield" })
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.BOUNDARY )
        newCharacter.icon = powerupManager.makePowerupIcon("shield")
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("characters"), 40, 4), false)
        ufo\doAction("spawn")

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
          attack: 15,
          speed: 40
        }

        powerupStats = {
          health: 2,
          shield: 1,
          strength: 2
        }

        actionIDs = {
          "supreme_jumpwalk"
        }
        x = ufo\getLocation()
        print "New location: #{x}"

        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs, x, -50, powerupStats)
        newCharacter\setPowerupDrops(0, 0, {})
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.DRAGGEDPOWERUP + entityCategory.BOUNDARY)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("characters"), 40, 4), false)
        ufo\doAction("spawn")

      when "ufo"
        print "UFO Character"
        rectangle = Rectangle(-64,-64,64,64)

        stats = {
          health: 100,
          speed: 0
        }

        actionIDs= {
          "fly"
        }

        newCharacter = UFO(characterID, prop, layer, world, direction.RIGHT, rectangle, stats, actionIDs, 0, 40, nil, false)
        ufo = newCharacter
        
        newCharacter.body = world\addBody( MOAIBox2DBody.KINEMATIC )
        newCharacter.body\setTransform 0, 20
        newCharacter.fixture = newCharacter.body\addCircle( 0, 15, 32 )
        newCharacter.fixture.parent = newCharacter
        newCharacter.fixture\setCollisionHandler(newCharacter.onCollide, MOAIBox2DArbiter.BEGIN)
        newCharacter.prop\setParent newCharacter.body
        newCharacter.prop.body = newCharacter.body

        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.POWERUP + entityCategory.BOUNDARY + entityCategory.INACTIVEPOWERUP + entityCategory.DRAGGEDPOWERUP)
      
      else
        print "Generic Character"
        rectangle = Rectangle(-32,-32,32,32)

        stats = {
          health: 100,
          speed 40
        }

        actionIDs = {
          "walk", "idle"
        }

        newCharacter = Character(characterID, prop, layer, world, direction.LEFT, rectangle, stats, actionIDs)
    table.insert(characters, newCharacter)
    newCharacter\add()
    return newCharacter

export characterManager = CharacterManager()
