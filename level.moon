export class Level
  new: (@configJson) =>
    @dataBuffer = MOAIDataBuffer.new!

  load: (onComplete) =>
    @dataBuffer\load(@configJson)
    @config = @dataBuffer\getString!

    @configTable = MOAIJsonParser.decode @config

    @length = @configTable.Level.length
    print "length #{@length}"

    assets = AssetLoader(@configTable.Level.assets)
    assets\load(onComplete)

    R\setAssets assets

  initialize: () =>
    print 'initializing'
    print 'creating layers'

    -- Generate layers
    LayerMgr\createLayer('background', 1, false)\render!\setParallax 0.5, 1
    LayerMgr\createLayer('ground', 2, false)\render!
    LayerMgr\createLayer('characters', 3, false)\render!
    LayerMgr\createLayer('box2d', 4, false)
    LayerMgr\createLayer('foreground', 5, false)\render!\setParallax 1.5, 1
    LayerMgr\createLayer('ui', 7, true, false)\render!
    LayerMgr\createLayer('powerups', 6, true)\render!

    -- Background color
    MOAIGfxDevice\getFrameBuffer()\setClearColor 1, 1, 0, 1

    -- Connect box2d to layer
    LayerMgr\getLayer('box2d')\setBox2DWorld( R.WORLD )

    -- De grond
    @staticBody = R.WORLD\addBody( MOAIBox2DBody.STATIC )
    @staticBody\setTransform(0,-100)

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

    gdeck = MOAITileDeck2D.new()
    gdeck\setTexture 'resources/ground.png'
    gdeck\setSize 1, 1

    -- Voorgrond prop
    fgprop = MOAIProp2D.new()
    fgprop\setDeck fgdeck
    fgprop\setGrid fggrid
    fgprop\setLoc -200, -120

    bgprop = MOAIProp2D.new()
    bgprop\setDeck bgdeck
    bgprop\setGrid bggrid
    bgprop\setLoc -200, -80

    gprop = MOAIProp2D.new()
    gprop\setDeck gdeck
    gprop\setGrid ggrid
    gprop\setLoc -200, -100

    LayerMgr\getLayer('foreground')\insertProp fgprop
    LayerMgr\getLayer('background')\insertProp bgprop
    LayerMgr\getLayer('ground')\insertProp gprop

    rectFixture   = @staticBody\addRect( -512, -15, 512, 15 )

    powerupManager.setLayerAndWorld(LayerMgr\getLayer('powerups'), R.WORLD)

    powerupManager.makePowerup("health", 170, 0)
    powerupManager.makePowerup("health", 200, 0)
    powerupManager.makePowerup("health", 230, 0)
    powerupManager.makePowerup("health", 260, 0)


    export direction = {
      LEFT: -1,
      RIGHT: 1
    }

    characterManager.setLayerAndWorld(LayerMgr\getLayer('characters'), R.WORLD)
    @c = characterManager.makeCharacter("hero")\add()
    @u = characterManager.makeCharacter("ufo")\add()

    btn = MOAIProp2D.new()
    button = CoolDownButton LayerMgr\getLayer("ui"), R.ASSETS.TEXTURES.BTN_ALIEN_RANK1, Rectangle(-16, -16, 16, 16), (200), (-120), 2, -> characterManager.makeCharacter("jumpwalker")
    button\add()

    button = CoolDownButton LayerMgr\getLayer("ui"), R.ASSETS.TEXTURES.BTN_ALIEN_RANK2, Rectangle(-16, -16, 16, 16), (160), (-120), 5, -> characterManager.makeCharacter("elite_jumpwalker")
    button\add()

    button = CoolDownButton LayerMgr\getLayer("ui"), R.ASSETS.TEXTURES.BTN_ALIEN_RANK3, Rectangle(-16, -16, 16, 16), (120), (-120), 4, -> characterManager.makeCharacter("supreme_jumpwalker")
    button\add()

    @startX = @c.body\getPosition()
    @indicator = Indicator(@startX, @length, LayerMgr\getLayer("ui"), 0, 150, -> print "game over")
    @indicator\add!

    @thread = MOAIThread.new()

  loop: () =>
    while true

      x = @c.body\getPosition()
      R.CAMERA\setLoc((x + 180))
      @staticBody\setTransform(x,-100)

      @u.body\setTransform((x + 360), -35)

      @indicator\update x

      -- print R.CAMERA\getLoc!

      coroutine.yield()

  destroy: () =>
    @assets\destroy()
    -- @LayerMgr\destroy()

  start: () =>
    print 'start'
    @thread\run(@\loop)

  pause: () =>
    -- Pause game

  end: () =>