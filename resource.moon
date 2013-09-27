class Resource
  new: () =>
    -- misschien later resources in json file zetten en uitlezen
    @WRESTLER_IDLE = MOAIImage.new()
    @WRESTLER_WALK = MOAIImage.new()
    -- @MUSHROOM = MOAIImage.new()

    @RED = MOAIImage.new()
    @GREEN = MOAIImage.new()
    @YELLOW = MOAIImage.new()

    -- @MUSHROOM2 = MOAIImage.new()
    -- @BUTTON = MOAITexture.new()
    -- @BUTTON2 = MOAITexture.new()
    -- @BUTTON3 = MOAITexture.new()

    -- @ALIEN = MOAIImage.new()
    -- @ALIEN2 = MOAIImage.new()
    -- @ALIEN3 = MOAIImage.new()
    -- @UFO = MOAIImage.new()


    @FONT = MOAIFont.new()
    @CHARCODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .!0123456789:-+"
    @STYLE = MOAITextStyle.new()
    @REDSTYLE = MOAITextStyle.new()
    @GREENSTYLE = MOAITextStyle.new()

    MOAIUntzSystem.initialize()
    @HIT = MOAIUntzSound.new()


    @setupViewport()

  load: () =>

    -- @WRESTLER_IDLE\load('resources/wrestler_idle.png')
    -- @WRESTLER_WALK\load('resources/wrestler_walk.png')
    -- @MUSHROOM\load('resources/mushroom.png')
    -- @MUSHROOM2\load('resources/mushroom2.png')
    -- @ALIEN\load('resources/alien_rank1.png')
    -- @ALIEN2\load('resources/alien_rank2.png')
    -- @ALIEN3\load('resources/alien_rank3.png')
    -- @UFO\load('resources/ufo.png')

    -- @BUTTON\load "resources/button_alien_rank1.png"
    -- @BUTTON2\load "resources/button_alien_rank2.png"
    -- @BUTTON3\load "resources/button_alien_rank3.png"

    @FONT\load("resources/arial-rounded.TTF")
    @FONT\preloadGlyphs(@CHARCODES, 20)
    @STYLE\setFont(@FONT)
    @STYLE\setSize(20)

    @REDSTYLE\setFont(@FONT)
    @REDSTYLE\setColor(1, 0, 0)

    @GREENSTYLE\setFont(@FONT)
    @GREENSTYLE\setColor(0, 1, 0)

    @RED\load("resources/red_health.png")
    @GREEN\load("resources/green_health.png")
    @YELLOW\load("resources/yellow_health.png")

    @HIT\load "resources/snare.wav"

    -- @WRESTLER_IDLE\load('resources/wrestler_idle.png')
    -- @WRESTLER_WALK\load('resources/wrestler_walk.png')
    -- @MUSHROOM\load('resources/mushroom.png')
    -- @MUSHROOM2\load('resources/mushroom2.png')
    -- @ALIEN\load('resources/alien_rank1.png')
    -- @ALIEN2\load('resources/alien_rank2.png')
    -- @ALIEN3\load('resources/alien_rank3.png')
    -- @UFO\load('resources/ufo.png')

    -- @BUTTON\load "resources/button_alien_rank1.png"
    -- @BUTTON2\load "resources/button_alien_rank2.png"
    -- @BUTTON3\load "resources/button_alien_rank3.png"

    -- @FONT\load("resources/arial-rounded.TTF")
    -- @FONT\preloadGlyphs(@CHARCODES, 20)
    -- @STYLE\setFont(@FONT)
    -- @STYLE\setSize(20)

    -- @RED\load("resources/red_health.png")
    -- @GREEN\load("resources/green_health.png")
    -- @YELLOW\load("resources/yellow_health.png")
    @loadWorld!

  loadWorld: () =>
    @WORLD = MOAIBox2DWorld.new()
    @WORLD\setGravity( 0, -10 ) -- Zwaartekracht
    @WORLD\setUnitsToMeters( 1/30 ) -- Hoeveel units in een meter. Let op dat Units niet per se pixels zijn, dat hangt af van de scale van de viewport
    @WORLD\start()


  loadJson: () =>
    @databuffer = MOAIDataBuffer.new()

  setupViewport: () =>

    @CAMERA = MOAICamera2D.new()

    @DEVICE_WIDTH = MOAIEnvironment.horizontalResolution or 480
    @DEVICE_HEIGHT = MOAIEnvironment.verticalResolution or 320

    units_y = 320
    units_x = units_y * @DEVICE_WIDTH/@DEVICE_HEIGHT

    print "DEVICE_WIDTH #{@DEVICE_WIDTH}"
    print "DEVICE_HEIGHT #{@DEVICE_HEIGHT}"

    @VIEWPORT = MOAIViewport.new()
    @VIEWPORT\setSize @DEVICE_WIDTH, @DEVICE_HEIGHT
    @VIEWPORT\setScale units_x, units_y

  setAssets: (assets) =>
    @ASSETS = assets

export R = Resource()