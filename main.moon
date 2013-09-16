io.stdout\setvbuf("no")
require 'characters'
export mouseX = 0
export mouseY = 0
-- Openen window
screenWidth = 1136
screenHeight = 640
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight

-- 1. Aanmaken van een viewport

viewport = MOAIViewport.new()
viewport\setSize screenWidth, screenHeight
viewport\setScale screenWidth, screenHeight

-- 2. Toevoegen van een layer

layer = MOAILayer2D.new()
layer\setViewport viewport
MOAIRenderMgr.pushRenderPass layer

-- 3. Achtergrondkleur instellen

MOAIGfxDevice\getFrameBuffer()\setClearColor 0, 0, 0, 1


-- Box2d WORLD
-- Wat je altijd nodig hebt is een Box2D wereld. Hier zie je niet per definitie iets van op het scherm
world = MOAIBox2DWorld.new()
world\setGravity( 0, -10 ) -- Zwaartekracht
world\setUnitsToMeters( 1/30 ) -- Hoeveel units in een meter. Let op dat Units niet per se pixels zijn, dat hangt af van de scale van de viewport
world\start()
layer\setBox2DWorld( world )


-- De grond
staticBody = world\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-200)

rectFixture   = staticBody\addRect( -512, -15, 512, 15 )

image = MOAIImage.new()
image\load "resources/mushroom.png"

p0 = Powerup world, layer, -400, 50, image
p1 = Powerup world, layer, -200, 50, image
p2 = Powerup world, layer, 0, 50, image
p3 = Powerup world, layer, 200, 50, image




newCharacter = (layer, world) ->

  texture = MOAIImage.new()
  texture\load('resources/texture.png')

  sprite = MOAIGfxQuad2D.new()
  sprite\setTexture(texture)
  sprite\setRect(-128, -128, 128, 128)

  -- Aanmaken prop
  prop = MOAIProp2D.new()
  prop\setDeck(sprite)
  prop\setLoc(0, 0)

  health = 100



  c = Character( prop, health, layer, world)
  c

c = newCharacter(layer, world)\add()
c\setBehaviour WalkBehaviour c



threadFunc = ->
  while true
    c\update()
    x, y = c.body\getPosition()
    -- viewport\setOffset(x, 0)
    -- print viewport\getLoc()
    coroutine.yield()

thread = MOAIThread.new()
thread\run(threadFunc)

p = Pointer(world, layer)

performWithDelay = (delay, func, repeats, ...) ->
  print 'performWithDelay'
  t = MOAITimer.new()
  t\setSpan delay/100
  print t\getTime()
  t\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
    print t\getTime()
    t\stop()
    t = nil
    func(unpack(arg))
    if repeats
      if repeats > 1
        performWithDelay( delay, func, repeats - 1, unpack( arg ) )
      elseif repeats == 0
        performWithDelay( delay, func, 0, unpack( arg ) ))
  t\start()

test = ->
  print 'delay'
  c\setBehaviour Behaviour c

test2 = ->
  print 'delay2'
  c\setBehaviour WalkBehaviour c

performWithDelay( 100, test )
performWithDelay( 200, test2 )
performWithDelay( 300, test )
performWithDelay( 400, test2 )



-- Clicks controleren
-- partition = layer\getPartition()

-- clickScreen = (down) ->
--   if down
--     pickedProp = partition\propForPoint mouseX, mouseY
--     print mouseX, mouseY
--     print pickedProp

-- trackPointer = (x, y) ->
--   mouseX, mouseY = layer\wndToWorld(x, y)

-- MOAIInputMgr.device.pointer\setCallback trackPointer
-- MOAIInputMgr.device.mouseLeft\setCallback clickScreen
-- ''