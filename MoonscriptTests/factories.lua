local BehaviorFactory
do
  local _base_0 = {
    getBehavior = function(behaviorID, character)
      if behaviorID == nil then
        behaviorID = ""
      end
      behaviorID = behaviorID:lower()
      print("Factory: " .. behaviorID)
      local _exp_0 = behaviorID
      if "walk" == _exp_0 then
        print("Walk Behavior")
        return WalkBehavior(character)
      elseif "punch" == _exp_0 then
        print("Punch Behavior")
        return PunchBehavior(character)
      elseif "kick" == _exp_0 then
        print("Kick Behavior")
        return KickBehavior(character)
      else
        print("Null Behavior")
        return NullBehavior(character)
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "BehaviorFactory"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  BehaviorFactory = _class_0
end
behaviorFactory = BehaviorFactory()
local CharacterFactory
do
  local _base_0 = {
    getCharacter = function(characterID, health, x, y, direction)
      if characterID == nil then
        characterID = ""
      end
      if health == nil then
        health = 0
      end
      if x == nil then
        x = 0
      end
      if y == nil then
        y = 0
      end
      if direction == nil then
        direction = direction.LEFT
      end
      characterID = characterID:lower()
      print("Factory: " .. characterID)
      local prop = MOAIProp2D.new()
      prop:setLoc(x, y)
      local _exp_0 = characterID
      if "hero" == _exp_0 then
        print("Hero Character")
        prop:setDeck(heroDeck)
        return Hero(prop, health, direction)
      elseif "enemy" == _exp_0 then
        print("Enemy Character")
        prop:setDeck(alienDeck)
        return Enemy(prop, health, direction)
      elseif "ufo" == _exp_0 then
        print("UFO Character")
        prop:setDeck(ufoDeck)
        return UFO(prop, health, direction)
      else
        print("Generic Character")
        prop:setDeck(heroDeck)
        return Character(prop, health, direction)
      end
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "CharacterFactory"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  CharacterFactory = _class_0
end
characterFactory = CharacterFactory()
