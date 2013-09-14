local AI
do
  local _base_0 = {
    think = function(character, otherCharacters)
      print("thinking")
      print(character)
      local actions = { }
      local _list_0 = character.behaviors
      for _index_0 = 1, #_list_0 do
        local behavior = _list_0[_index_0]
        table.insert(actions, behavior)
      end
      return actions
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "AI"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AI = _class_0
end
ai = AI()
