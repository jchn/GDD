class Screen

	new: (@configJson) =>
    	@dataBuffer = MOAIDataBuffer.new!

	load: (onComplete) =>
	    @dataBuffer\load(@configJson)
	    @config = @dataBuffer\getString!

	    @configTable = MOAIJsonParser.decode @config

	    assets = AssetLoader(@configTable.Level.assets)
	    assets\load(onComplete)

	    R\setAssets assets

export class MainMenuScreen extends Screen

	open: () =>
		screenLayer = LayerMgr\createLayer('screen', 0, true, false)
		print "SCREEN LAYER = #{screenLayer}"
		screenLayer\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor 0, .2, 1, 1

		button = SimpleButton(LayerMgr\getLayer("screen"), R.ASSETS.IMAGES["HEALTH"], Rectangle(-16, -16, 16, 16), 0, 0, -> gameManager.openLevel(1))
		button\add()

	close: () =>
		LayerMgr\destroyAllLayers!