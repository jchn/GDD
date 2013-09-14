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


-- health = 100

-- texture = MOAIImage.new()
-- texture\load('resources/texture.png')

-- sprite = MOAIGfxQuad2D.new()
-- sprite\setTexture(texture)
-- sprite\setRect(-128, -128, 128, 128)

-- Aanmaken prop
prop = MOAIProp2D.new()
prop\setDeck(sprite)
prop\setLoc(0, 0)

-- Aanmaken behaviour
behaviour = RotateBehaviour()

c = Hero( prop, health, behaviour, layer)
c\add()
c\method()
c\update()

p = Pointer(world, layer)
print 'test'

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