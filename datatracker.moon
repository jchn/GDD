class DataTracker
  new: () =>
    @powerups = {}
    @units = {}

  addPowerupForCharacter: (powerup, character) =>
    return if not powerup.specificName
    return if not character.name

    if not @powerups[character.name]
      @powerups[character.name] = {}
      e\triggerEvent("FIRST_POWERUP_FOR_"..character.name\upper!, powerup)

    if not @powerups[character.name][powerup.specificName]
      e\triggerEvent("FIRST_"..powerup.specificName\upper!.."_FOR_"..character.name\upper!, powerup)
      @powerups[character.name][powerup.specificName] = 1
    else
      e\triggerEvent(powerup.specificName\upper!.."_FOR_"..character.name, powerup)
      @powerups[character.name][powerup.specificName] += 1


  addSpawnedUnit: (unit) =>
    return if not unit.characterID
    if not @units[unit.characterID]
      e\triggerEvent("SPAWNED_FIRST_"..unit.characterID\upper!.."_UNIT", unit)
      @units[unit.characterID] = 1
    else
      @units[unit.characterID] += 1

  reset: () =>
    @powerups = {}
    @units = {}

export dt = DataTracker!
