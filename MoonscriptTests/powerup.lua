do
  local _base_0 = { }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, behaviorID)
      self.behaviorID = behaviorID
      return print("Powerup Initialized")
    end,
    __base = _base_0,
    __name = "Powerup"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Powerup = _class_0
end
