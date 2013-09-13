io.stdout\setvbuf("no")
require 'characters'
export mouseX = 0
export mouseY = 0
-- Openen window
screenWidth = 1136
screenHeight = 640
MOAISim.openWindow "whack-a-mole", screenWidth, screenHeight

-- 1. Aanmaken van een viewport

viewport = MOAIViewport.new()
viewport\setSize screenWidth, screenHeight
viewport\setScale screenWidth, screenHeight

-- 2. Toevoegen van een layer

layer = MOAILayer2D.new()
layer\setViewport viewport
MOAIRenderMgr.pushRenderPass layer

-- 3. Achtergrondkleur instellen

MOAIGfxDevice\getFrameBuffer()\setClearColor 1, 1, 1, 1



health = 100

texture = MOAIImage.new()
texture\load('resources/texture.png')

sprite = MOAIGfxQuad2D.new()
sprite\setTexture(texture)
sprite\setRect(-128, -128, 128, 128)

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

-- Clicks controleren
partition = layer\getPartition()

clickScreen = (down) ->
  if down
    pickedProp = partition\propForPoint mouseX, mouseY
    print mouseX, mouseY
    print pickedProp

trackPointer = (x, y) ->
  mouseX, mouseY = layer\wndToWorld(x, y)

MOAIInputMgr.device.pointer\setCallback trackPointer
MOAIInputMgr.device.mouseLeft\setCallback clickScreen
''