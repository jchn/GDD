require("character")
require("AI")
require("behavior")
require("factories")
require("graphics")
local gameName = "Aliens versus Wrestler"
local screenWidth = 800
local screenHeight = 480
MOAISim.openWindow(gameName, screenWidth, screenHeight)
direction = {
  LEFT = -1,
  RIGHT = 1,
  NONE = 0
}
gameSpeed = 1 / 2
local viewport = MOAIViewport.new()
viewport:setSize(screenWidth, screenHeight)
viewport:setScale(screenWidth, screenHeight)
local layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAIRenderMgr.pushRenderPass(layer)
local characters = { }
removeCharacter = function(character)
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #characters do
      local char = characters[_index_0]
      if char ~= character then
        _accum_0[_len_0] = char
        _len_0 = _len_0 + 1
      end
    end
    characters = _accum_0
  end
end
getOtherCharacters = function(character)
  return (function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #characters do
      local char = characters[_index_0]
      if char ~= character then
        _accum_0[_len_0] = char
        _len_0 = _len_0 + 1
      end
    end
    return _accum_0
  end)()
end
local spawnCharacter
spawnCharacter = function(characterID, health, x, y, direction, layer, behaviorIDs)
  if behaviorIDs == nil then
    behaviorIDs = { }
  end
  local c = characterFactory.getCharacter(characterID, health, x, y, direction)
  table.insert(characters, c)
  c:addToLayer(layer)
  for _index_0 = 1, #behaviorIDs do
    local behaviorID = behaviorIDs[_index_0]
    c:addBehavior(behaviorID)
  end
  return c
end
local update
update = function()
  print("update")
  local x = 1
  for _index_0 = 1, #characters do
    local char = characters[_index_0]
    if not (char == nil) then
      print(x)
      char:update()
      x = x + 1
    end
  end
end
spawnCharacter("hero", 60, -300, -150, direction.RIGHT, layer, {
  "walk",
  "punch"
})
spawnCharacter("ufo", 60, 300, 40, direction.LEFT, layer)
local rightClickHandler
rightClickHandler = function(down)
  print(down)
  if down then
    return spawnCharacter("enemy", 10, 300, -150, direction.LEFT, layer, {
      "walk"
    })
  end
end
MOAIInputMgr.device.mouseRight:setCallback((rightClickHandler))
local gameloop = MOAITimer.new()
gameloop:setMode(MOAITimer.LOOP)
gameloop:setSpan(gameSpeed)
gameloop:setListener(MOAITimer.EVENT_TIMER_END_SPAN, update)
gameloop:start()
pause = function()
  return gameloop:pause()
end
