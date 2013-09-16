export class Action --behavior

  execute: (character, otherCharacters) =>
    character.state = Characterstate.EXECUTING

  stop: (character, otherCharacters) =>
    character.state = Characterstate.FINISHING
    if @beforeStop  @beforeStop()
    character.state = Characterstate.IDLE

export class IdleAction extends Action
  execute: (character, otherCharacters) =>
    super
    curve = MOAIAnimCurve.new()
    curve\reserveKeys(2)

    curve\setKey(1, 0.25, 1)
    curve\setKey(2, 0.5, 2)

    anim = MOAIAnim\new()
    anim\reserveLinks(1)
    anim\setLink(1, curve, character.prop, MOAIProp2D.ATTR_INDEX)
    anim\setMode(MOAITimer.LOOP)
    anim\setSpan(1)
    anim\start()
