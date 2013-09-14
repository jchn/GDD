do
  local _base_0 = {
    alterHealth = function(self, deltaHealth)
      self.health = self.health + deltaHealth
    end,
    die = function(self)
      print("Character Died")
      self.alive = false
      self.health = 0
    end,
    addBehavior = function(self, behaviorID)
      print("Character: " .. behaviorID)
      local behavior = behaviorFactory.getBehavior(behaviorID, self)
      return table.insert(self.behaviors, behavior)
    end,
    printBehaviors = function(self)
      print("Character Behaviors")
      local _list_0 = self.behaviors
      for _index_0 = 1, #_list_0 do
        local behavior = _list_0[_index_0]
        behavior.printInfo()
      end
    end,
    update = function(self)
      local _list_0 = self.behaviors
      for _index_0 = 1, #_list_0 do
        local behavior = _list_0[_index_0]
        behavior:execute(getOtherCharacters(self))
      end
      if self.health <= 0 and self.alive then
        return self:die()
      end
    end,
    addToLayer = function(self, layer)
      self.layer = layer
      print(self.prop)
      print("Adding to layer")
      return self.layer:insertProp(self.prop)
    end,
    removeFromLayer = function(self)
      return self.layer:removeProp(self.prop)
    end,
    move = function(self, deltaX, deltaY, speed)
      return self.prop:moveLoc(deltaX * self.direction, deltaY, speed)
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, prop, health, direction)
      self.prop, self.health, self.direction = prop, health, direction
      self.alive = true
      print("Character Initialized")
      self.behaviors = { }
    end,
    __base = _base_0,
    __name = "Character"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Character = _class_0
end
do
  local _parent_0 = Character
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Hero",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Hero = _class_0
end
do
  local _parent_0 = Character
  local _base_0 = {
    die = function(self)
      self:removeFromLayer()
      local _ = _parent_0
      return removeCharacter(self)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Enemy",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Enemy = _class_0
end
do
  local _parent_0 = Character
  local _base_0 = {
    die = function(self)
      local _ = _parent_0
      return pause()
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "UFO",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        return _parent_0[name]
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  UFO = _class_0
end
