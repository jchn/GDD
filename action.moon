class Action --behavior

  new: (@character) =>

  execute: () =>
    @character.state = Characterstate.EXECUTING

  stop: () =>
    @character.state = Characterstate.FINISHING
    if @beforeStop
      @beforeStop(otherCharacters)
    @character.state = Characterstate.IDLE
    @character\update()

  poll: () =>
    return true, 0

class ChangeDirectionAction extends Action

  execute: () =>
    if @character.state == Characterstate.IDLE
      @character.direction *= -1
      super @character
      @stop!

  selectCharacters: () =>
    characterManager.selectCharacters((char) ->
      x1, y1 = char\getLocation()
      x2, y2 = @character\getLocation()

      return (char.name == 'hero' or char.name == 'ufo') and char.direction != @character.direction and (x1 >= x2 - 90 and x1 <= x2 + 90) )

  poll: () =>
    otherCharacters = @selectCharacters()
    return true, (#otherCharacters * 500)    

class IdleAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES[@character.characterID\upper! .. "_IDLE"]

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(2, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(2)

      @curve\setKey(1, 0.25, 1)
      @curve\setKey(2, 0.5, 2)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)
      @anim\setSpan(1)
      @anim\start()
    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, 100

class WallAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES[@character.characterID\upper! .. "_WALL"]

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(4, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(4)

      @curve\setKey(1, 0.25, 1)
      @curve\setKey(2, 0.5, 2)
      @curve\setKey(3, 0.75, 3)
      @curve\setKey(4, 1, 4)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)
      @anim\setSpan(1.25)
      @anim\start()
    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, 100

class RangedAttackAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES[@character.characterID\upper! .. "_RANGED_ATTACK"]

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(8, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(11)

      @curve\setKey(1, 0.2, 1)
      @curve\setKey(2, 0.4, 2)
      @curve\setKey(3, 0.6, 3)
      @curve\setKey(4, 0.8, 1)
      @curve\setKey(5, 1.0, 2)
      @curve\setKey(6, 1.2, 3)
      @curve\setKey(7, 1.4, 4)
      @curve\setKey(8, 1.6, 5)
      @curve\setKey(9, 1.8, 6)
      @curve\setKey(10, 2.0, 7)
      @curve\setKey(11, 2.2, 8)

      span = 3
      if @character.stats.ranged_cooldown != nil
        span = @character.stats.ranged_cooldown

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.NORMAL)
      @anim\setSpan(2.4)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)

      @timer = MOAITimer.new()
      @timer\setSpan(2.0)
      @timer\setMode(MOAITimer.NORMAL)
      @timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\update)
      @timer\start()

    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil
    @timer\stop()
    @timer = nil

  update: () =>
    x, y = @character\getLocation()
    bullet = powerupManager.makePowerup("bullet", x, y + 10)
    bullet.body\setLinearVelocity(-200, 0)
    bullet\setPotency(@character.stats.attack * -1)

class PunchAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.WRESTLER_KICK

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(2, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(2)

      @curve\setKey(1, 0.0, 1)
      @curve\setKey(2, 0.2, 2)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.NORMAL)
      @anim\setSpan(0.6)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)

      @timer = MOAITimer.new()
      @timer\setSpan(0.3)
      @timer\setMode(MOAITimer.NORMAL)
      @timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\update)
      @timer\start()

    super @character

  selectCharacters: (range) =>
    characterManager.selectCharacters((char) ->
      x1, y1 = char\getLocation()
      x2, y2 = @character\getLocation()

      return char.name == 'unit' and (x1 >= x2 - 20 and x1 <= x2 + range) )

  update: () =>
    otherCharacters = @selectCharacters(55)

    if #otherCharacters > 0
      for char in *otherCharacters do
        char\alterHealth(-@character.stats.attack)

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil
    @timer\stop()
    @timer = nil

  poll: () =>
    otherCharacters = @selectCharacters(55)
    return true, 90 + (#otherCharacters * 100) + math.random(0,12)

class WalkAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES[@character.characterID\upper! .. "_WALK"]

      rect = @character.rectangle


      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)

      if @character.characterID\upper! == "COLLECTOR"
        @tileLib\setSize(6, 1)
      else
        @tileLib\setSize(4, 2)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(6)

      @curve\setKey(1, 0.0, 1)
      @curve\setKey(2, 0.16, 2)
      @curve\setKey(3, 0.33, 3)
      @curve\setKey(4, 0.50, 4)
      @curve\setKey(5, 0.66, 5)
      @curve\setKey(6, 0.83, 6)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(1.0)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\test)
      -- @anim\stop(otherCharacters)

      @character.body\setLinearVelocity(@character.stats.speed * @character.direction, 0)
    super @character

  test: =>
    @stop!

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @character.body\setLinearVelocity(0, 0)
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, 100

class RunAction extends WalkAction

  execute: () =>
    super @character
    @character.body\setLinearVelocity((@character.stats.speed * 2) * @character.direction, 0)

  selectCharacters: () =>
    powerupManager.selectPowerups((powerup) ->
      x1, y1 = powerup.body\getPosition()
      x2, y2 = @character\getLocation()

      return powerup.name == 'powerup' and powerup.active and not powerup.isDragged and (x1 >= x2 and x1 <= x2 + 100) )

  poll: () =>
    otherCharacters = @selectCharacters()
    return true, 90 + (#otherCharacters * 20)

class FlyAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.UFO

      print "Executing fly action!"

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(4, 5)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(2)

      rnd = math.random(1, 8)

      if rnd == 1
        @curve\setKey(1, 0.25, 1)
        @curve\setKey(2, 0.75, 3)
      elseif rnd == 2
        @curve\setKey(1, 0.25, 1)
        @curve\setKey(2, 0.75, 4)
      else
        @curve\setKey(1, 0.25, 1)
        @curve\setKey(2, 0.75, 2)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.NORMAL)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)
      @anim\setSpan(1)
      @anim\start()

    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil
    print "DONE FLYING"

  poll: (otherCharacters = {}) =>
    return true, 1

class CrashAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.UFO

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(4, 5)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(9)

      @curve\setKey(1, 0.25, 9)
      @curve\setKey(2, 0.5, 10)
      @curve\setKey(3, 0.75, 11)
      @curve\setKey(4, 0.1, 12)
      @curve\setKey(5, 1.25, 13)
      @curve\setKey(6, 1.5, 14)
      @curve\setKey(7, 1.75, 15)
      @curve\setKey(8, 2.0, 16)
      @curve\setKey(9, 2.25, 17)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.NORMAL)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN)
      @anim\setSpan(3)
      @anim\start()

    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, 1

class SpawnAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.UFO

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(4, 5)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(4)

      @curve\setKey(1, 0.2, 5)
      @curve\setKey(2, 0.4, 6)
      @curve\setKey(3, 0.6, 7)
      @curve\setKey(4, 0.8, 8)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\stop)
      @anim\setSpan(1)
      @anim\start()

    super @character

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, math.random(0,1000)

class JumpwalkAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES[@character.characterID\upper! .. "_JUMPWALK"]

      rect = @character.rectangle


      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(6, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(8)

      @curve\setKey(1, 0.00, 1)
      @curve\setKey(2, 0.10, 2)
      @curve\setKey(3, 0.20, 3)

      @curve\setKey(4, 0.40, 4)
      @curve\setKey(5, 0.80, 5)
      @curve\setKey(6, 1.20, 4)
      @curve\setKey(7, 1.60, 5)

      @curve\setKey(8, 1.80, 6)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(2.0)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\test)
      -- @anim\stop(otherCharacters)

      @timer = MOAITimer.new()
      @timer\setSpan(2.0/16)
      @timer\setMode(MOAITimer.LOOP)
      @timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\update)
      @timer\start()
      @counter = 1
      @jumpTable = { 0, 60, 40, 30, 20, 10, 0, 0, -10, -20, -30, -40, -60, 0, 0, 0 }

    super @character

  update: () =>
    @character.body\setLinearVelocity(@character.stats.speed * @character.direction, @jumpTable[@counter])
    @counter += 1
    otherCharacters = @selectCharacters()

    if #otherCharacters > 0
      @character.body\setLinearVelocity(0, 0)
      for char in *otherCharacters do
        char\alterHealth(-@character.stats.attack)
      died = @character\alterHealth(-5)

      if not died
        @timer\stop()
        @anim\stop()
        @x, @y = @character\getLocation()

        deltaX = (120 + @character.stats.speed) / 24
        deltaY = (@y + 3 - (-50)) / 18
        @counter = 1

        @timer = MOAITimer.new()
        @timer\setSpan(1/24)
        @timer\setMode(MOAITimer.LOOP)
        @timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
          @x += deltaX
          if @counter > 6
            @y -= deltaY
          else
            @y += 0.5
          @character.body\setTransform(@x , @y)
          @counter += 1
          if @counter  == 24
            @\stop())
        @timer\start()


  selectCharacters: () =>
    characterManager.selectCharacters((char) ->
      x1, y1 = char\getLocation()
      x2, y2 = @character\getLocation()

      return char.name == 'hero' and (x1 >= x2 - 20 and x1 <= x2 + 20) )

  test: =>
    @stop!

  beforeStop: (otherCharacters = {}) =>
    @timer\stop()
    @anim\stop()
    @character.body\setLinearVelocity(0, 0)
    @anim = nil
    @timer = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, math.random(0,800)
 
class ActionManager
  makeAction: (actionID, character) ->
    actionID = actionID\lower()

    switch actionID
      when "idle"
        IdleAction(character)

      when "wall"
        WallAction(character)

      when "walk"
        WalkAction(character)

      when "punch"
        PunchAction(character)

      when "ranged_attack"
        RangedAttackAction(character)

      when "run"
        RunAction(character)

      when "jumpwalk"
        JumpwalkAction(character)

      when "spawn"
        SpawnAction(character)

      when "fly"
        FlyAction(character)

      when "crash"
        CrashAction(character)

      when "changedirection"
        ChangeDirectionAction(character)


export actionManager = ActionManager()
