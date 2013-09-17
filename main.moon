io.stdout\setvbuf("no")
require 'rectangle'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'resource'
export mouseX = 0
export mouseY = 0
-- Openen window
screenWidth = 480
screenHeight = 320
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()

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
-- layer\setBox2DWorld( world )


-- De grond
staticBody = world\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-100)

rectFixture   = staticBody\addRect( -512, -15, 512, 15 )

p0 = Powerup world, layer, -400, 50, R.MUSHROOM
p1 = Powerup world, layer, -200, 50, R.MUSHROOM
p2 = Powerup world, layer, 0, 50, R.MUSHROOM
p3 = Powerup world, layer, 200, 50, R.MUSHROOM

newCharacter = (layer, world) ->

  texture = MOAIImage.new()
  texture\load('resources/wrestler_idle.png')

  rect = Rectangle 0, -64, 64, 64
  rect\subtract( 32, 32, 32, 32 )

  tileLib = MOAITileDeck2D\new()
  tileLib\setTexture(texture)
  tileLib\setSize(2, 1)
  tileLib\setRect(rect\get())

  -- Aanmaken prop
  prop = MOAIProp2D.new()
  prop\setDeck(tileLib)
  prop\setLoc(0, 0)
  prop\setColor 1.0, 1.0, 1.0, 1.0
  prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

  health = 100

  c = Character( prop, layer, world, 1, rect )
  c

c = newCharacter(layer, world)\add()
c\addBehavior IdleAction()

threadFunc = ->
  while true
    c\update!
    -- x, y = c.body\getPosition()
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
  c\addBehavior IdleAction c

test2 = ->
  print 'delay2'
  c\addBehavior WalkAction c

performWithDelay( 0, test )
performWithDelay( 400, test2 )
performWithDelay( 800, test )
performWithDelay( 1000, test2 )
