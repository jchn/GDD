require("character")
require("AI")
require("behavior")
require("factories")
require("graphics")

gameName = "Aliens versus Wrestler"
screenWidth = 800
screenHeight = 480

MOAISim.openWindow(gameName, screenWidth, screenHeight)

export direction = {
  LEFT: -1,
  RIGHT: 1,
  NONE: 0
}

export gameSpeed = 1/2

viewport = MOAIViewport.new()
viewport\setSize(screenWidth, screenHeight)
viewport\setScale(screenWidth, screenHeight)

layer = MOAILayer2D.new()
layer\setViewport(viewport)
MOAIRenderMgr.pushRenderPass(layer)

characters = {}

export removeCharacter = (character) ->
	characters = [char for char in *characters when char != character]

export getOtherCharacters = (character) ->
	return [char for char in *characters when char != character]

spawnCharacter = (characterID, health, x, y, direction, layer, behaviorIDs = {}) ->
	c = characterFactory.getCharacter(characterID, health, x, y, direction)
	table.insert(characters, c)
	c\addToLayer(layer)

	for behaviorID in *behaviorIDs do
		c\addBehavior(behaviorID)

	return c

update = ->
	print "update"
	x = 1

	for char in *characters do
		unless char == nil
			print x
			char\update()
			x += 1

spawnCharacter("hero", 60, -300, -150, direction.RIGHT, layer, { "walk", "punch" })
spawnCharacter("ufo", 60, 300, 40, direction.LEFT, layer)

rightClickHandler = (down) ->
	print down
	if down
		spawnCharacter("enemy", 10, 300, -150, direction.LEFT, layer, { "walk" })

MOAIInputMgr.device.mouseRight\setCallback ( rightClickHandler )

gameloop = MOAITimer.new()
gameloop\setMode(MOAITimer.LOOP)
gameloop\setSpan(gameSpeed)
gameloop\setListener(MOAITimer.EVENT_TIMER_END_SPAN, update)
gameloop\start()

export pause = ->
	gameloop\pause()