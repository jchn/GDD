class ScreenManager

	screens = {}
	currentScreen = nil

	registerScreen: (screenID, screen) ->
		print "Registered screen: #{screenID}"
		screens[screenID] = screen

	closePrevious: () ->
		if currentScreen != nil
			currentScreen\close!
			currentScreen = nil
		clearPointer()

	openScreen: (screenID) ->
		print "Opening screen: #{screenID}"
		screenManager.closePrevious!
		currentScreen = screens[screenID]
		currentScreen\load!
		currentScreen\open!

	makeScreenElement: (layer, screenElementConfig) ->
		elementID = screenElementConfig.ELEMENT\lower!

		switch elementID
			when "button"
				size = screenElementConfig.SIZE
				print "Making button with size: #{size[1]}"
				button = SimpleButton(layer, R.ASSETS.IMAGES[screenElementConfig.IMAGE], Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X, screenElementConfig.Y, -> screenManager.doScreenElementFunctions(screenElementConfig.FUNCTION))
				button\add()

	doScreenElementFunctions: (functionInfo) ->
		print "Function Info = #{functionInfo}"
		functionInfo = splitAtSpaces(functionInfo)
		functionInfo[1] = functionInfo[1]\lower!

		switch functionInfo[1]
			when "openscreen"
				screenManager.openScreen(functionInfo[2])

export screenManager = ScreenManager()

class Screen

	new: (@configJson) =>

	load: (onComplete = -> print "Loading Complete") =>
		dataBuffer = MOAIDataBuffer.new!
		dataBuffer\load(@configJson)
		config = dataBuffer\getString!

		@configTable = MOAIJsonParser.decode config
		@configTable = @configTable.Config

		assets = AssetLoader(@configTable.assets)
		assets\load(onComplete)

		R\setAssets assets

	open: () =>
		print "Opening Screen"

	close: () =>
		print "Closing Screen"
		LayerMgr\destroyAllLayers!

export class GameScreen extends Screen

	load: (onComplete = -> print "Loading Complete") =>
		super (onComplete)
		@screenElements = @configTable.screenElements

	open: () =>
		screenLayer = LayerMgr\createLayer('screen', 1, true, false)\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor 0, .2, 1, 1

		for screenElement in *@screenElements
			screenManager.makeScreenElement(screenLayer, screenElement)

export class Level extends Screen

	load: (onComplete = -> print "Loading complete") =>
		super (onComplete)
		@length = @configTable.length
		@wrestler = @configTable.wrestler
		@spawnableUnits = @configTable.spawnableUnits
		@startingPowerups = @configTable.startingPowerups
		print "Length of level: #{@length}, Wrestler: #{@wrestler}"

	open: () =>
		LayerMgr\createLayer('background', 1, false)\render!\setParallax 0.5, 1
		LayerMgr\createLayer('ground', 2, false)\render!
		LayerMgr\createLayer('characters', 3, false)\render!
		LayerMgr\createLayer('box2d', 4, false)
		LayerMgr\createLayer('foreground', 5, false)\render!\setParallax 1.5, 1
		LayerMgr\createLayer('ui', 7, true, false)\render!
		LayerMgr\createLayer('powerups', 6, true)\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor .5, .5, .5, 1

		LayerMgr\getLayer('box2d')\setBox2DWorld( R.WORLD )

		@ground = R.WORLD\addBody( MOAIBox2DBody.STATIC )
		@ground\setTransform(0,-100)
		@ground\addRect( -512, -15, 512, 15 )

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

		characterManager.setLayerAndWorld(LayerMgr\getLayer('characters'), R.WORLD)
		powerupManager.setLayerAndWorld(LayerMgr\getLayer('powerups'), R.WORLD)

		@wrestler = characterManager.makeCharacter(@wrestler)\add()
		@ufo = characterManager.makeCharacter("ufo")\add()

		buttonX = 200
		buttonY = -120
		buttonXOffset = -40
		for spawnableUnit in *@spawnableUnits 
			button = CoolDownButton LayerMgr\getLayer("ui"), R.ASSETS.TEXTURES["#{spawnableUnit}_button"\upper!], Rectangle(-16, -16, 16, 16), buttonX, buttonY, 2, (-> characterManager.makeCharacter(spawnableUnit)), (-> return characterManager.checkEnemySpawnable(spawnableUnit))
			button\add()
			buttonX += buttonXOffset

		for startingPowerup in *@startingPowerups
			powerupManager.makePowerup(startingPowerup.ID, startingPowerup.X, startingPowerup.Y)\activate!
 
		@startX = @wrestler.body\getPosition()
		@indicator = Indicator(@startX, @length, LayerMgr\getLayer("ui"), 0, 150, @gameOver)
		@indicator\add!

		@running = true
		@thread = MOAIThread.new()
		@thread\run(@\loop)
		print "Opened level"

	loop: () =>
		while @running
			x = @wrestler.body\getPosition()
			R.CAMERA\setLoc((x + 180))
			@ground\setTransform(x,-100)
			@ufo.body\setTransform((x + 360), -35)
			@indicator\update x
			coroutine.yield()

	close: () =>
		@running = false
		LayerMgr\destroyAllLayers!
		characterManager.clear()
		@thread = nil
		@ground = nil
		@wrestler = nil
		@startX = nil
		@indicator = nil
		@length = nil
		
		
	gameOver: () =>
		print "Game Over!"