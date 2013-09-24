class Resource
  new: () =>
    -- misschien later resources in json file zetten en uitlezen
    @WRESTLER_IDLE = MOAIImage.new()
    @WRESTLER_WALK = MOAIImage.new()
    @MUSHROOM = MOAIImage.new()

    @SCREEN_WIDTH = 480*2
    @SCREEN_HEIGHT = 320*2
    @VIEWPORT = MOAIViewport.new()
    @VIEWPORT\setSize @SCREEN_WIDTH, @SCREEN_HEIGHT
    @VIEWPORT\setScale @SCREEN_WIDTH/2, @SCREEN_HEIGHT/2

    @WORLD = MOAIBox2DWorld.new()
    @WORLD\setGravity( 0, -10 ) -- Zwaartekracht
    @WORLD\setUnitsToMeters( 1/30 ) -- Hoeveel units in een meter. Let op dat Units niet per se pixels zijn, dat hangt af van de scale van de viewport
    @WORLD\start()

    @BUTTON = MOAITexture.new()

    @ALIEN = MOAIImage.new()
    @UFO = MOAIImage.new()
  load: () =>
    @WRESTLER_IDLE\load('resources/wrestler_idle.png')
    @WRESTLER_WALK\load('resources/wrestler_walk.png')
    @MUSHROOM\load('resources/mushroom.png')
    @ALIEN\load('resources/alien.png')
    @UFO\load('resources/ufo.png')

    @BUTTON\load "resources/button_alien_rank1.png"

  loadJson: () =>
    @databuffer = MOAIDataBuffer.new()

export R = Resource()