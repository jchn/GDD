local AbstractBehavior
do
  local _base_0 = {
    execute = function(self, otherCharacters)
      return print("Behavior Executing")
    end,
    printInfo = function(self)
      return print("Behavior class")
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, character)
      self.character = character
      print("Behavior Initialized")
      return print(self.character)
    end,
    __base = _base_0,
    __name = "AbstractBehavior"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AbstractBehavior = _class_0
end
do
  local _parent_0 = AbstractBehavior
  local _base_0 = {
    printInfo = function(self)
      return print("Null Behavior")
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "NullBehavior",
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
  NullBehavior = _class_0
end
do
  local _parent_0 = AbstractBehavior
  local _base_0 = {
    printInfo = function(self)
      return print("Walk Behavior")
    end,
    execute = function(self, otherCharacters)
      local _ = _parent_0
      return self.character:move(10, 0, gameSpeed)
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "WalkBehavior",
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
  WalkBehavior = _class_0
end
do
  local _parent_0 = AbstractBehavior
  local _base_0 = {
    printInfo = function(self)
      return print("Punch Behavior")
    end,
    execute = function(self, otherCharacters)
      for _index_0 = 1, #otherCharacters do
        local char = otherCharacters[_index_0]
        char:alterHealth(-2)
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "PunchBehavior",
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
  PunchBehavior = _class_0
end
do
  local _parent_0 = AbstractBehavior
  local _base_0 = {
    printInfo = function(self)
      return print("Kick Behavior")
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  local _class_0 = setmetatable({
    __init = function(self, ...)
      return _parent_0.__init(self, ...)
    end,
    __base = _base_0,
    __name = "KickBehavior",
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
  KickBehavior = _class_0
end
