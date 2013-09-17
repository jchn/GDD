export class Action --behavior

  execute: (character, otherCharacters) =>
    character.state = Characterstate.EXECUTING

  stop: (character, otherCharacters) =>
    character.state = Characterstate.FINISHING
    if @beforeStop
      @beforeStop(character, otherCharacters)
    character.state = Characterstate.IDLE

export class IdleAction extends Action
  execute: (character, otherCharacters) =>
    if character.state == Characterstate.IDLE
      print 'setting animation from behavior'

      texture = R.WRESTLER_IDLE
      print 'mushroom'
      print R.MUSHROOM
      rect = Rectangle 0, -64, 64, 64
      rect\subtract( 32, 32, 32, 32 )

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(2, 1)
      @tileLib\setRect(rect\get())

      character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(2)

      @curve\setKey(1, 0.25, 1)
      @curve\setKey(2, 0.5, 2)

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1)
      @anim\setLink(1, @curve, character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(1)
      @anim\start()
    super character

  beforeStop: (character, otherCharacters) =>
    @anim\stop()
    @anim = nil
    @curve = nil

export class WalkAction extends Action
  execute: (character, otherCharacters) =>
    if character.state == Characterstate.IDLE

      texture = R.WRESTLER_WALK

      rect = Rectangle 0, -64, 64, 64
      rect\subtract( 32, 32, 32, 32 )

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(6, 1)
      @tileLib\setRect(rect\get())

      character.prop\setDeck @tileLib

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
      @anim\setLink(1, @curve, character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setSpan(1.0)
      @anim\start()

      character.body\setLinearVelocity(40, 0)
    super character

  beforeStop: (character, otherCharacters) =>
    @anim\stop()
    character.body\setLinearVelocity(0, 0)
    @anim = nil
    @curve = nil
