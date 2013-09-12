io.stdout\setvbuf("no")
-- Openen window
screenWidth = 320
screenHeight = 480
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
