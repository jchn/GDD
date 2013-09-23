io.stdout\setvbuf("no")
require 'rectangle'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'resource'
require 'ai'
export _ = require 'underscore'

export mouseX = 0
export mouseY = 0

-- Openen window
screenWidth = 480
screenHeight = 320
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()

camera = MOAICamera2D.new()

-- 1. Aanmaken van een viewport
viewport = MOAIViewport.new()
viewport\setSize screenWidth, screenHeight
viewport\setScale screenWidth, screenHeight

-- 2. Toevoegen van een layer
characterLayer = MOAILayer2D.new()
characterLayer\setViewport viewport
characterLayer\setCamera camera
MOAIRenderMgr.pushRenderPass characterLayer

powerupLayer = MOAILayer2D.new()
powerupLayer\setViewport viewport
powerupLayer\setCamera camera
MOAIRenderMgr.pushRenderPass powerupLayer

-- 3. Achtergrondkleur instellen
MOAIGfxDevice\getFrameBuffer()\setClearColor 0, 0, 0, 1

-- Box2d WORLD
-- Wat je altijd nodig hebt is een Box2D wereld. Hier zie je niet per definitie iets van op het scherm
world = MOAIBox2DWorld.new()
world\setGravity( 0, -10 ) -- Zwaartekracht
world\setUnitsToMeters( 1/30 ) -- Hoeveel units in een meter. Let op dat Units niet per se pixels zijn, dat hangt af van de scale van de viewport
world\start()
--characterLayer\setBox2DWorld( world )

-- De grond
staticBody = world\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-100)

rectFixture   = staticBody\addRect( -512, -15, 512, 15 )

powerupManager.setLayerAndWorld(powerupLayer, world)
powerupManager.makePowerup("health", 170, 0, R.MUSROOM)
powerupManager.makePowerup("health", 200, 0, R.MUSROOM)
powerupManager.makePowerup("health", 230, 0, R.MUSROOM)
powerupManager.makePowerup("health", 260, 0, R.MUSROOM)

export direction = {
  LEFT: -1,
  RIGHT: 1
}

characterManager.setLayerAndWorld(characterLayer, world)
c = characterManager.makeCharacter("hero")\add()
u = characterManager.makeCharacter("ufo")\add()

threadFunc = ->
  while true

    x = c.body\getPosition()
    camera\setLoc((x + 180))
    staticBody\setTransform(x,-100)

    u.body\setTransform((x + 360), -35)

    coroutine.yield()

thread = MOAIThread.new()
thread\run(threadFunc)

export p = Pointer(world, powerupLayer)

performWithDelay = (delay, func, repeats, ...) ->
  t = MOAITimer.new()
  t\setSpan delay/100
  -- print t\getTime()
  t\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
    -- print t\getTime()
    t\stop()
    t = nil
    func(unpack(arg))
    if repeats
      if repeats > 1
        performWithDelay( delay, func, repeats - 1, unpack( arg ) )
      elseif repeats == 0
        performWithDelay( delay, func, 0, unpack( arg ) ))
  t\start()

rightclickCallback = (down) ->
  if down
    characterManager.makeCharacter("unit")\add()
MOAIInputMgr.device.mouseRight\setCallback ( rightclickCallback )
