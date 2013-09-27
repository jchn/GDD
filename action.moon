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

class IdleAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.WRESTLER_IDLE

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
    return true, math.random(0,1000)

class WalkAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.WRESTLER_WALK

      rect = @character.rectangle


      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(6, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(6)

      @curve\setKey(1, 0.16, 1)
      @curve\setKey(2, 0.33, 2)
      @curve\setKey(3, 0.50, 3)
      @curve\setKey(4, 0.66, 4)
      @curve\setKey(5, 0.83, 5)
      @curve\setKey(6, 1.00, 6)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(1.0)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\test)
      -- @anim\stop(otherCharacters)

      @character.body\setLinearVelocity(40 * @character.direction, 0)
    super @character

  test: =>
    print 'stop'
    @stop!

  beforeStop: (otherCharacters = {}) =>
    @anim\stop()
    @character.body\setLinearVelocity(0, 0)
    @anim = nil
    @curve = nil

  poll: (otherCharacters = {}) =>
    return true, math.random(0,800)

class FlyAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.UFO

      rect = @character.rectangle

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(8, 1)
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
    return true, math.random(0,1000)

class JumpwalkAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.ASSETS.IMAGES.ALIEN

      rect = @character.rectangle


      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(6, 1)
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(6)

      @curve\setKey(1, 0.20, 1)
      @curve\setKey(2, 0.30, 2)
      @curve\setKey(3, 0.50, 3)
      @curve\setKey(4, 1.80, 4)
      @curve\setKey(5, 1.90, 5)
      @curve\setKey(6, 2.00, 6)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(2.0)
      @anim\start()
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\test)
      -- @anim\stop(otherCharacters)

      @timer = MOAITimer.new()
      @timer\setSpan(2.0/15)
      @timer\setMode(MOAITimer.LOOP)
      @timer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\update)
      @timer\start()
      @counter = 1
      @jumpTable = { 60, 40, 30, 20, 10, 0, 0, -10, -20, -30, -40, -60, 0, 0, 0 }

    super @character

  update: () =>
    @character.body\setLinearVelocity(60 * @character.direction, @jumpTable[@counter])
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

        deltaX = 160 / 24
        deltaY = (@y + 3 - (-70)) / 18
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
    print 'stop'
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

class EliteJumpwalkAction extends JumpwalkAction

  execute: (otherCharacters = {}) =>
    super @character
    texture = R.ASSETS.IMAGES.ALIEN2
    @tileLib\setTexture(texture)
    print "Elite Jumpwalker!"    

class SupremeJumpwalkAction extends JumpwalkAction

  execute: (otherCharacters = {}) =>
    super @character
    texture = R.ASSETS.IMAGES.ALIEN3
    @tileLib\setTexture(texture)
    print "Elite Jumpwalker!"   

class ActionManager
  makeAction: (actionID, character) ->
    actionID = actionID\lower()
    print "Action Factory: " .. actionID

    switch actionID
      when "idle"
        print "Idle Action"
        IdleAction(character)

      when "walk"
        print "Walk Action"
        WalkAction(character)

      when "jumpwalk"
        JumpwalkAction(character)

      when "elite_jumpwalk"
        EliteJumpwalkAction(character)

      when "supreme_jumpwalk"
        SupremeJumpwalkAction(character)

      when "fly"
        FlyAction(character)


export actionManager = ActionManager()
