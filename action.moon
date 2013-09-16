export class Action --behavior

  execute: (character, otherCharacters) =>
    character.state = Characterstate.EXECUTING

  stop: (character, otherCharacters) =>
    character.state = Characterstate.FINISHING
    if @beforeStop  @beforeStop()
    character.state = Characterstate.IDLE