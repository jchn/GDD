io.stdout\setvbuf("no")
export camera = MOAICamera2D.new()
require 'resource'
require 'rectangle'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'ai'
require 'simplebutton'
require 'layermanager'

export _ = require 'lib/underscore'

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
LayerMgr\createLayer('ui', 2, true, false)\render!
LayerMgr\createLayer('box2d', 3, false)
LayerMgr\createLayer('powerups', 4, true)\render!

-- 3. Achtergrondkleur instellen
MOAIGfxDevice\getFrameBuffer()\setClearColor 0, 0, 0, 1

-- Box2d WORLD
LayerMgr\getLayer('box2d')\setBox2DWorld( R.WORLD )

-- De grond
staticBody = R.WORLD\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-100)

rectFixture   = staticBody\addRect( -512, -15, 512, 15 )

powerupManager.setLayerAndWorld(LayerMgr\getLayer('powerups'), R.WORLD)
powerupManager.makePowerup("health", 170, 0, R.MUSROOM)
powerupManager.makePowerup("health", 200, 0, R.MUSROOM)
powerupManager.makePowerup("health", 230, 0, R.MUSROOM)
powerupManager.makePowerup("health", 260, 0, R.MUSROOM)

export direction = {
  LEFT: -1,
  RIGHT: 1
}

characterManager.setLayerAndWorld(LayerMgr\getLayer('characters'), R.WORLD)
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

btn = MOAIProp2D.new()
button = SimpleButton LayerMgr\getLayer("ui"), R.BUTTON, Rectangle(-16, -16, 16, 16), (200), (-120), -> characterManager.makeCharacter("unit")\add()
button\add()
