class Resource
  new: () =>

    @FONT = MOAIFont.new()
    @CHARCODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz .!0123456789:-+"
    @STYLE = MOAITextStyle.new()
    @REDSTYLE = MOAITextStyle.new()
    @GREENSTYLE = MOAITextStyle.new()

    MOAIUntzSystem.initialize()
    @HIT = MOAIUntzSound.new()


    @setupViewport()

  load: () =>

    @FONT\load("resources/arial-rounded.TTF")
    @FONT\preloadGlyphs(@CHARCODES, 20)
    @STYLE\setFont(@FONT)
    @STYLE\setSize(20)

    @REDSTYLE\setFont(@FONT)
    @REDSTYLE\setColor(1, 0, 0)

    @GREENSTYLE\setFont(@FONT)
    @GREENSTYLE\setColor(0, 1, 0)

    @HIT\load "resources/snare.wav"

  loadJson: () =>
    @databuffer = MOAIDataBuffer.new()

  setupViewport: () =>

    @CAMERA = MOAICamera2D.new()

    @DEVICE_WIDTH = MOAIEnvironment.horizontalResolution or 480
    @DEVICE_HEIGHT = MOAIEnvironment.verticalResolution or 320

    units_y = 320
    units_x = units_y * @DEVICE_WIDTH/@DEVICE_HEIGHT

    @VIEWPORT = MOAIViewport.new()
    @VIEWPORT\setSize @DEVICE_WIDTH, @DEVICE_HEIGHT
    @VIEWPORT\setScale units_x, units_y

  setAssets: (assets) =>
    @ASSETS = assets

  setLevel: (level) =>
    @LEVEL = level


export R = Resource()