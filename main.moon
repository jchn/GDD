io.stdout\setvbuf("no")
require 'resource'
require 'rectangle'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'ai'
require 'simplebutton'
require 'layermanager'

export mouseX = 0
export mouseY = 0
-- Openen window
screenWidth = 480
screenHeight = 320
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()

-- 1. Aanmaken van een viewport


-- 2. Toevoegen van een layer

LayerMgr\createLayer('characters', 1, true)\render!
LayerMgr\createLayer('powerups', 2, true)\render!
LayerMgr\createLayer('powerups', 3, true)\render!
LayerMgr\createLayer('box2d', 4, false)

layer2 = MOAILayer2D.new()
layer2\setViewport viewport
MOAIRenderMgr.pushRenderPass layer2

-- 3. Achtergrondkleur instellen

MOAIGfxDevice\getFrameBuffer()\setClearColor 0, 0, 0, 1

-- Box2d WORLD
LayerMgr\getLayer('box2d')\setBox2DWorld( R.WORLD )


-- De grond
staticBody = R.WORLD\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-100)

rectFixture   = staticBody\addRect( -512, -15, 512, 15 )

p0 = Powerup R.WORLD, LayerMgr\getLayer('powerups'), 100, 50, R.MUSHROOM
p1 = Powerup R.WORLD, LayerMgr\getLayer('powerups'), -200, 50, R.MUSHROOM
p2 = Powerup R.WORLD, LayerMgr\getLayer('powerups'), 0, 50, R.MUSHROOM
p3 = Powerup R.WORLD, LayerMgr\getLayer('powerups'), 200, 50, R.MUSHROOM

export direction = {
  LEFT: -1,
  RIGHT: 1
}

c = characterManager.makeCharacter("hero", LayerMgr\getLayer('characters'), R.WORLD)\add()

for i = 1, 3
  characterManager.makeCharacter("unit", LayerMgr\getLayer('characters'), R.WORLD)\add()

<<<<<<< HEAD
print 'c'
print c
--a = IdleAction(c)
--c\addBehavior(a)
btn = MOAIProp2D.new()
button = SimpleButton layer, R.BUTTON, Rectangle(-64, -64, 64, 64), -> print 'derp'
button\add()
=======
>>>>>>> layermgr

threadFunc = ->
  while true

    characterManager.updateCharacters()

    coroutine.yield()

thread = MOAIThread.new()
thread\run(threadFunc)

performWithDelay = (delay, func, repeats, ...) ->
  t = MOAITimer.new()
  t\setSpan delay/100
  t\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
    t\stop()
    t = nil
    func(unpack(arg))
    if repeats
      if repeats > 1
        performWithDelay( delay, func, repeats - 1, unpack( arg ) )
      elseif repeats == 0
        performWithDelay( delay, func, 0, unpack( arg ) ))
  t\start()

performWithDelay( 400, -> characterManager.removeCharacters((char) -> return char != c))

otherChars = characterManager.selectCharacters((i) -> return i != c)

print "OTHER CHARACTERS"
for oChar in *otherChars do
  print oChar
