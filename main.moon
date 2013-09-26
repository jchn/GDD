io.stdout\setvbuf("no")
export camera = MOAICamera2D.new()
require 'resource'
require 'rectangle'
require 'healthbar'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'ai'
require 'simplebutton'
require 'layermanager'
require 'PowerupInfobox'

export _ = require 'lib/underscore'

export mouseX = 0
export mouseY = 0

-- Openen window
screenWidth = R.DEVICE_WIDTH
screenHeight = R.DEVICE_HEIGHT
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()


-- 1. Aanmaken van een viewport


-- 2. Toevoegen van een layer

LayerMgr\createLayer('background', 1, false)\render!\setParallax 0.5, 1
LayerMgr\createLayer('ground', 2, false)\render!
LayerMgr\createLayer('characters', 3, false)\render!
LayerMgr\createLayer('box2d', 4, false)
LayerMgr\createLayer('foreground', 5, false)\render!\setParallax 1.5, 1
LayerMgr\createLayer('ui', 7, true, false)\render!
LayerMgr\createLayer('powerups', 6, true)\render!

-- 3. Achtergrondkleur instellen
MOAIGfxDevice\getFrameBuffer()\setClearColor 1, 1, 0, 1

-- Box2d WORLD
LayerMgr\getLayer('box2d')\setBox2DWorld( R.WORLD )

-- De grond
staticBody = R.WORLD\addBody( MOAIBox2DBody.STATIC )
staticBody\setTransform(0,-100)

-- De voorgrond
fggrid = MOAIGrid.new()
fggrid\initRectGrid 8, 1, 279, 279
fggrid\setRow 1, 1, 1, 1, 1, 1, 1, 1, 1

bggrid = MOAIGrid.new()
bggrid\initRectGrid 8, 1, 279, 279
bggrid\setRow 1, 1, 1, 1, 1, 1, 1, 1, 1

ggrid = MOAIGrid.new()
ggrid\initRectGrid 8, 1, 279, 279
ggrid\setRow 1, 1, 1, 1, 1, 1, 1, 1, 1

-- Voorgrond deck
fgdeck = MOAITileDeck2D.new()
fgdeck\setTexture 'resources/fg.png'
fgdeck\setSize 1, 1

bgdeck = MOAITileDeck2D.new()
bgdeck\setTexture 'resources/bg.png'
bgdeck\setSize 1, 1

-- bgdeck\setUVRect -10, -10, 10, 10

gdeck = MOAITileDeck2D.new()
gdeck\setTexture 'resources/ground.png'
gdeck\setSize 1, 1

-- Voorgrond prop
fgprop = MOAIProp2D.new()
fgprop\setDeck fgdeck
fgprop\setGrid fggrid
fgprop\setLoc 0, -120

bgprop = MOAIProp2D.new()
bgprop\setDeck bgdeck
bgprop\setGrid bggrid
bgprop\setLoc 0, -80

gprop = MOAIProp2D.new()
gprop\setDeck gdeck
gprop\setGrid ggrid
gprop\setLoc 0, -100

LayerMgr\getLayer('foreground')\insertProp fgprop
LayerMgr\getLayer('background')\insertProp bgprop
LayerMgr\getLayer('ground')\insertProp gprop

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

export performWithDelay = (delay, func, repeats, ...) ->
  t = MOAITimer.new()
  t\setSpan delay
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
button = CoolDownButton LayerMgr\getLayer("ui"), R.BUTTON, Rectangle(-16, -16, 16, 16), (200), (-120), 2, -> characterManager.makeCharacter("jumpwalker")
button\add()

button = CoolDownButton LayerMgr\getLayer("ui"), R.BUTTON2, Rectangle(-16, -16, 16, 16), (160), (-120), 5, -> characterManager.makeCharacter("elite_jumpwalker")
button\add()
