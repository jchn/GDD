export Characterstate = {
  IDLE: 0
  EXECUTING: 1
  FINISHING: 2
}

class Character

  name: 'character'

  new: (@characterID, @prop, @layer, @world, @direction, @rectangle, @bodyRectangle, @stats, actionIDs, @x = 0, @y = 0, @powerupStats = { health: 1, shield: 1, strength: 1 }, makeDefaultBody = true) =>
    @state = Characterstate.IDLE
    @body = nil
    @fixture = nil

    if makeDefaultBody == true
      @body = @world\addBody( MOAIBox2DBody.KINEMATIC )
      @body\setTransform @x, @y

      @fixture = @body\addRect( @bodyRectangle\get() )
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
    @immortal = false
    @add()
    @update()

  getHeight: () =>
    return @bodyRectangle\getHeight()

  getWidth: () =>
    return @bodyRectangle\getWidth()

  setFilter: (category, mask) =>
    @fixture\setFilter(category, mask)

  getLocation: () =>
    return @body\getPosition()

  setImmortal: (@immortal) =>

  showFloatingNumber: (text, length, style, offsetX = 0, offsetY = 0) =>
    x, y = @getLocation()
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

  alterHealth: (deltaHealth, pierce = false) =>
    if deltaHealth < 0
      if @stats.shield
        if @stats.shield > 0 and pierce == false
          @stats.shield -= 1

          if @stats.shield <= 0
            @layer\removeProp @icon
            @icon = nil
          return
      @colorBlink(1.0, 0.0, 0.0)

    if @immortal == false
      @stats.health += deltaHealth

    if @stats.health > @stats.maxHealth
      @stats.maxHealth = @stats.health
    
    if @healthbar
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

  doAction: (actionID) =>
    @currentAction\beforeStop()
    @state = Characterstate.IDLE
    @currentAction = actionManager.makeAction(actionID, @)
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
    if other.name == 'powerup' or other.name == 'bullet'
      if other.prop.isDragged
        Pntr\clear()
      powerupManager.removePowerups((p) -> return p == other)
      other\remove()
      other\destroy()
      other\execute(own)
      own\colorBlink(0.0, 1.0, 0.0)
    if other.name == 'powerup'
      performWithDelay(0.2, -> dt\addPowerupForCharacter(other, own))
      

class Hero extends PowerupUser

  name: 'hero'

  alterHealth: (deltaHealth, pierce) =>
    if pierce and @stats.shield > 0
      deltaHealth *= 2

    super deltaHealth, pierce
    if deltaHealth >= 0
      @showFloatingNumber("+#{deltaHealth}", 2, R.GREENSTYLE)
    else
      @showFloatingNumber("#{deltaHealth}", 2, R.REDSTYLE)
      R.HIT\play!

  die: () =>
    dt\addDeadUnit(@)
    

class Unit extends PowerupUser

  name: 'unit'

  setPowerupDrops: (@minDrops, @maxDrops, @possibleDrops) =>

  die: () =>
    x, y = @getLocation()
    super super
    if @minDrops != nil and @maxDrops != nil and @possibleDrops != nil

      drops = math.random(@minDrops, @maxDrops)

      for i  = 1, drops do
        dropping = math.random(#@possibleDrops)

        powerup = powerupManager.makePowerup(@possibleDrops[dropping], (x - 10 + (i * 10)) , y)
        powerup.body\applyLinearImpulse(100,100)
        timer = MOAITimer.new()
        timer\setSpan(1)
        timer\setMode(MOAITimer.NORMAL)
        timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
          powerup\activate!)
        timer\start()
    performWithDelay(0.2, -> dt\addDeadUnit(@))

class CollectorUnit extends Unit

  onCollide: (own, other, event) =>
    own = own.parent
    other = other.parent
    if other.name == 'powerup'
      if other.prop.isDragged
        Pntr\clear()
      other\remove()
      other\destroy()
      own\colorBlink(0.0, 1.0, 0.0, 1.00)
      skill = 1
      if own.stats.collectSkill != nil
        skill = own.stats.collectSkill

      amount = characterManager.collectPowerup(other.specificName, skill)
      if amount >= 0
        own\showFloatingNumber("+#{amount}", 4, R.GREENSTYLE)
      else
        style = R.REDSTYLE
        own\showFloatingNumber("#{amount}", 4, R.REDSTYLE)
      powerupManager.removePowerups((p) -> return p == other)

  die: () =>
    super @
    buttonManager.enableButtons()

class UFO extends Character

  name: 'ufo'

  onCollide: (own, other, event) =>
    own = own.parent
    other = other.parent
    if other.name == 'powerup'
      performWithDelay(0.2, -> dt\addPowerupForCharacter(other, own))
      if other.prop.isDragged
        Pntr\clear()
      other\remove()
      other\destroy()
      own\colorBlink(0.0, 1.0, 0.0, 1.00)
      amount = characterManager.collectPowerup(other.specificName)
      if amount >= 0
        own\showFloatingNumber("+#{amount}", 4, R.GREENSTYLE)
      else
        style = R.REDSTYLE
        own\showFloatingNumber("#{amount}", 4, R.REDSTYLE)
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
  configTable = {}
  spawnedCharacters = {}

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

  checkEnemySpawnable: (characterID) ->
    characterID = characterID\upper()

    if characterID == "COLLECTOR"
      collectorCharacters = characterManager.selectCharacters((char) -> return char.characterID\upper() == characterID)
      if #collectorCharacters > 0
        return false

    if configTable[characterID].COST == nil
      return true
    for powerup, amount in pairs configTable[characterID].COST do
      powerup = powerup\lower()
      if collectedPowerups[powerup] == nil
        return false
      if collectedPowerups[powerup] < amount
        return false
    return true

  payCost: (characterID) ->
    characterID = characterID\upper()
    if configTable[characterID].COST == nil
      return
    for powerup, amount in pairs configTable[characterID].COST do
      powerup = powerup\lower()
      collectedPowerups[powerup] -= amount
    characterManager.updatePowerupCounters!
    
  updatePowerupCounters: () ->
    x, y = 200, 130
    offsetX, offsetY = -60, 0

    for powerupInfobox in *powerupInfoboxes do
      powerupInfobox\remove()

    for powerUpID, amount in pairs collectedPowerups do
      graphic = powerupManager.getGraphic(powerUpID)
      powerupInfobox = PowerupInfobox(graphic, Rectangle(-16, -16, 16, 16), "#{amount}", Rectangle(0, 0, 30, 25), R.ASSETS.STYLES.ARIAL, LayerMgr\getLayer("ui"), x, y, powerUpID)
      powerupInfobox\add()
      x += offsetX
      y += offsetY
      table.insert(powerupInfoboxes, powerupInfobox)

  collectPowerup: (powerupSpecificName, amount = 1) ->
    powerupSpecificName = powerupSpecificName\lower!
    if collectedPowerups[powerupSpecificName] == nil
      collectedPowerups[powerupSpecificName] = 0

    collectedPowerups[powerupSpecificName] += amount
    if collectedPowerups[powerupSpecificName] > 99
      collectedPowerups[powerupSpecificName] = 99

    characterManager.updatePowerupCounters()
    buttonManager.enableButtons()
    return amount

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

  setConfigTable: (newConfigTable) ->
    configTable = newConfigTable

  getConfigTable: (characterID) ->
    characterID = characterID\upper!
    return deepcopy(configTable[characterID])

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
    spawnedCharacters = {}

  saveSpawnedUnits: () ->
    for char in *spawnedCharacters do
      alreadySaved = false

      for char2 in *saveFile.Save.SPAWNED_UNITS
        if char == char2
          alreadySaved = true

      if alreadySaved == false
        table.insert(saveFile.Save.SPAWNED_UNITS, char)

    save()

  makeCharacter: (characterID) ->
    characterID = characterID\upper()
    prop = MOAIProp2D.new()
    prop\setLoc(0, 0)
    prop\setColor 1.0, 1.0, 1.0, 1.0
    -- prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

    newCharacter = {}
    characterConfig = characterManager.getConfigTable(characterID)
  
    rectangle = Rectangle(characterConfig.RECTANGLE[1], characterConfig.RECTANGLE[2], characterConfig.RECTANGLE[3], characterConfig.RECTANGLE[4])
    bodyRectangle = rectangle

    if characterConfig.BODYRECTANGLE != nil
      bodyRectangle = Rectangle(characterConfig.BODYRECTANGLE[1], characterConfig.BODYRECTANGLE[2], characterConfig.BODYRECTANGLE[3], characterConfig.BODYRECTANGLE[4])

    stats = characterConfig.STATS
    powerupStats = characterConfig.POWERUP_STATS
    actions = characterConfig.ACTIONS
    y = characterConfig.SPAWNLOCATION_OFFSET

    minLoot = characterConfig.MIN_LOOT
    maxLoot = characterConfig.MAX_LOOT
    possibleLoot = characterConfig.POSSIBLE_LOOT
    canUsePowerups = characterConfig.CAN_USE_POWERUPS
    characterType = characterConfig.TYPE
    immortal = characterConfig.IMMORTAL

    proxyID = characterConfig.PROXY_ID
    if proxyID != nil
      characterID = proxyID\upper!

    if characterManager.checkEnemySpawnable(characterID)
      characterManager.payCost(characterID)
    else
      return

    switch characterID
      when "WRESTLER"
        newCharacter = Hero(characterID, prop, layer, world, direction.RIGHT, rectangle, bodyRectangle, stats, actions, x, y, powerupStats)
        if immortal == false or immortal == nil
          newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("ui"), 100, 10))
        else
          newCharacter\setImmortal(true)
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.POWERUP + entityCategory.BOUNDARY + entityCategory.BULLET)
        newCharacter\doAction("idle")
      when "COLLECTOR", "ELITE_COLLECTOR", "SUPREME_COLLECTOR"
        x = ufo\getLocation()
        newCharacter = CollectorUnit(characterID, prop, layer, world, direction.LEFT, rectangle, bodyRectangle, stats, actions, x, y)
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.POWERUP + entityCategory.BOUNDARY + entityCategory.INACTIVEPOWERUP + entityCategory.DRAGGEDPOWERUP)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("characters"), newCharacter\getWidth(), 4), false)
        ufo\doAction("spawn")
      when "UFO"
        newCharacter = UFO(characterID, prop, layer, world, direction.LEFT, rectangle, bodyRectangle, stats, actions, 0, y, nil, false)
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
        x = ufo\getLocation()
        newCharacter = Unit(characterID, prop, layer, world, direction.LEFT, rectangle, bodyRectangle, stats, actions, x, y, powerupStats)
        newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.BOUNDARY)
        newCharacter\setHealthbar(Healthbar(LayerMgr\getLayer("characters"), newCharacter\getWidth(), 4), false)
        ufo\doAction("spawn")

    if minLoot != nil and maxLoot != nil and possibleLoot != nil
      newCharacter\setPowerupDrops(minLoot, maxLoot, possibleLoot )
    
    if newCharacter.stats.shield > 0
      newCharacter.icon = powerupManager.makePowerupIcon("shield")

    if canUsePowerups
      newCharacter\setFilter(entityCategory.CHARACTER, entityCategory.DRAGGEDPOWERUP + entityCategory.BOUNDARY)

    table.insert(characters, newCharacter)
    newCharacter\add()

    if characterType == "unit"
      performWithDelay(0.2, -> dt\addSpawnedUnit(newCharacter))
      hasSpawnedThisUnit = false
      for char in *spawnedCharacters do
        if char == characterID
          hasSpawnedThisUnit = true

      if hasSpawnedThisUnit == false
        table.insert(spawnedCharacters, characterID)
    return newCharacter

export characterManager = CharacterManager()
