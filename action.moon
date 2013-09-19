class Action --behavior

  new: (@character) =>

  execute: (otherCharacters = {}) =>
    @character.state = Characterstate.EXECUTING

  stop: (otherCharacters = {}) =>
    @character.state = Characterstate.FINISHING
    if @beforeStop
      @beforeStop(otherCharacters)
    @character.state = Characterstate.IDLE

  getOtherCharacters: () =>

  poll: (otherCharacters = {}) =>
    return true, 0

class IdleAction extends Action

  execute: (otherCharacters = {}) =>
    if @character.state == Characterstate.IDLE

      texture = R.WRESTLER_IDLE

      rect = Rectangle -32, -32, 32, 32

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

      texture = R.WRESTLER_WALK

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

      @character.body\setLinearVelocity(40, 0)
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
    return true, math.random(0,900)

class AttackAction extends Action

  new: (@character) =>

  execute: () =>
    super
    -- Voor de actie uit. Alle betrokken characters krijgen 2 damage.
    for char in getOtherCharacters() do
      char.alterHealth(-2)

  stop: (otherCharacters = {}) =>
    super

  getOtherCharacters: () =>
    -- Haalt alle andere characters op binnen een bepaalde range.
    -- Dit zijn de characters die geraakt kunnen worden door de aanval.
    minX = @character.getLocation()
    return getOtherCharacters(@character, minX, minX + 10)

  poll: () =>
    -- Voorbeeld voor de poll functie
    -- Deze aanval kan altijd worden uitgevoerd
    -- De score is in dit geval de damage die gedaan kan worden (er moet overal dezelfde metric gekozen worden)
    return true, table.getn(otherCharacters) * 2 

class ActionFactory
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

      else
        print "Generic Action"
        IdleAction(character)


export actionFactory = ActionFactory()
