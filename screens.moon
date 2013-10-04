class ScreenManager

	screens = {}
	currentScreen = nil

	levelRunning: () ->
		return currentScreen.running

	registerScreen: (screenID, screen) ->
		screens[screenID] = screen

	closePrevious: () ->
		if currentScreen != nil
			currentScreen\close!
			currentScreen = nil
		clearPointer()
		LayerMgr\destroyAllLayers!
		characterManager.clear()
		buttonManager.clear()


	openScreen: (screenID) ->
		screenManager.closePrevious!
		currentScreen = screens[screenID]
		currentScreen\load!
		currentScreen\open!

	makeScreenElement: (layer, screenElementConfig) ->
		elementID = screenElementConfig.ELEMENT\lower!

		switch elementID
			when "button"
				size = screenElementConfig.SIZE
				
				button = SimpleButton(layer, R.ASSETS.IMAGES[screenElementConfig.IMAGE], Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X, screenElementConfig.Y, (-> screenManager.doScreenElementFunctions(screenElementConfig.FUNCTION)), (-> screenManager.doScreenElementFunctions(screenElementConfig.ENABLE_FUNCTION)) )
				button\add()

	doScreenElementFunctions: (functionInfo) ->
		functionInfo = splitAtSpaces(functionInfo)
		functionInfo[1] = functionInfo[1]\lower!
		print "DO SCREEN ELMENT FUNCTION: #{functionInfo[1]}"
		switch functionInfo[1]
			when "openscreen"
				screenManager.openScreen(functionInfo[2])
			when "levelunlocked"
				print "Level unlocked"
				saveFile.Save.CURRENT_LEVEL >= tonumber(functionInfo[2])

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

	close: () =>

export class GameScreen extends Screen

	load: (onComplete = -> print "Loading Complete") =>
		super (onComplete)
		@screenElements = @configTable.screenElements

	open: () =>
		screenLayer = LayerMgr\createLayer('screen', 1, true, false)\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor 0, .2, 1, 1

		for screenElement in *@screenElements
			screenManager.makeScreenElement(screenLayer, screenElement)

export levelState = {
	MADE: 0
	LOADED: 1
	RUNNING: 2
	LEVEL_LOST: 3,
	LEVEL_WON: 4
}

export class Level extends Screen

	new: (@configJson, @levelNO) =>
		super
		@state = levelState.MADE

	load: (onComplete = -> print "Loading complete") =>
		super (onComplete)
		@length = @configTable.length
		@wrestler = @configTable.wrestler
		@spawnableUnits = @configTable.spawnableUnits
		@startingPowerups = @configTable.startingPowerups

		@state = levelState.LOADED

		@world = MOAIBox2DWorld.new()
		@world\setGravity( 0, -10 ) -- Zwaartekracht
		@world\setUnitsToMeters( 1/30 ) -- Hoeveel units in een meter. Let op dat Units niet per se pixels zijn, dat hangt af van de scale van de viewport
		@world\start()

		Pntr\setWorld(@world)


	open: () =>
		@state = levelState.RUNNING
		LayerMgr\createLayer('background', 1, false)\render!\setParallax 0.5, 1
		LayerMgr\createLayer('ground', 2, false)\render!
		LayerMgr\createLayer('characters', 3, false)\render!
		LayerMgr\createLayer('box2d', 4, false)
		LayerMgr\createLayer('foreground', 5, false)\render!\setParallax 1.5, 1
		LayerMgr\createLayer('ui', 7, true, false)\render!
		LayerMgr\createLayer('powerups', 6, true)\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor .2980, .1372, .2, 1

		LayerMgr\getLayer('box2d')\setBox2DWorld( @world )

		@ground = @world\addBody( MOAIBox2DBody.STATIC )
		@ground\setTransform(0,-100)
		@ground\addRect( -512, -15, 512, 15 )

		-- De voorgrond
		fggrid = MOAIGrid.new()
		fggrid\initRectGrid 1, 1, 279, 279
		fggrid\setRow 1, 1
		fggrid\setRepeat(true, false)

		bggrid = MOAIGrid.new()
		bggrid\initRectGrid 1, 1, 279, 279
		bggrid\setRow 1, 1
		bggrid\setRepeat(true, false)

		ggrid = MOAIGrid.new()
		ggrid\initRectGrid 1, 1, 279, 279
		ggrid\setRow 1, 1
		ggrid\setRepeat(true, false)

		-- Voorgrond deck
		fgdeck = MOAITileDeck2D.new()
		fgdeck\setTexture 'resources/fg.png'
		fgdeck\setSize 1, 1

		bgdeck = MOAITileDeck2D.new()
		bgdeck\setTexture 'resources/bg2.png'
		bgdeck\setSize 1, 1

		gdeck = MOAITileDeck2D.new()
		gdeck\setTexture 'resources/ground.png'
		gdeck\setSize 1, 1

		-- Voorgrond prop
		fgprop = MOAIProp2D.new()
		fgprop\setDeck fgdeck
		fgprop\setGrid fggrid
		fgprop\setLoc 0, -100

		bgprop = MOAIProp2D.new()
		bgprop\setDeck bgdeck
		bgprop\setGrid bggrid
		bgprop\setLoc 0, -60

		gprop = MOAIProp2D.new()
		gprop\setDeck gdeck
		gprop\setGrid ggrid
		gprop\setLoc 0, -80

		LayerMgr\getLayer('foreground')\insertProp fgprop
		LayerMgr\getLayer('background')\insertProp bgprop
		LayerMgr\getLayer('ground')\insertProp gprop

		characterManager.setLayerAndWorld(LayerMgr\getLayer('characters'), @world)
		powerupManager.setLayerAndWorld(LayerMgr\getLayer('powerups'), @world)

		@wrestler = characterManager.makeCharacter(@wrestler)\add()
		@ufo = characterManager.makeCharacter("ufo")\add()

		buttonX = 200
		buttonXInitial = buttonX
		buttonY = -90
		buttonYOffset = -50
		buttonXOffset = -50
		buttonCount = 0
		for spawnableUnit in *@spawnableUnits 
			button = CoolDownButton LayerMgr\getLayer("ui"), R.ASSETS.TEXTURES["#{spawnableUnit}_button"\upper!], Rectangle(-16, -16, 16, 16), buttonX, buttonY, 2, (-> characterManager.makeCharacter(spawnableUnit)), (-> return characterManager.checkEnemySpawnable(spawnableUnit))
			button\add()
			buttonX += buttonXOffset
			buttonCount += 1
			if buttonCount % 9 == 0
				buttonX = buttonXInitial
				buttonY += buttonYOffset

		for startingPowerup in *@startingPowerups
			powerupManager.makePowerup(startingPowerup.ID, startingPowerup.X, startingPowerup.Y)\activate!
 
		@startX = @wrestler.body\getPosition()
		@indicator = Indicator(@startX, @length, LayerMgr\getLayer("ui"), -170, 150, @\gameOver)
		@indicator\add!

		@running = true
		@thread = MOAIThread.new()
		@thread\run(@\loop)

	loop: () =>
		while @running
			characterManager.updateCharacters()
			switch @state
				when levelState.RUNNING
					
					x = @wrestler.body\getPosition()
					R.CAMERA\setLoc((x + 180))
					@ground\setTransform(x,-80)
					@ufo.body\setTransform((x + 360), -15)
					@indicator\update x
					if @wrestler.stats.health <= 0
						@win()

					bullets = powerupManager.selectPowerups((powerup) ->
      					x1, y1 = powerup.body\getPosition()
      					x2, y2 = @wrestler\getLocation()

      					return powerup.name == 'bullet' and (x1 >= x2 - 20 and x1 <= x2 + 20) )

					if #bullets > 0
						for bullet in *bullets do
							powerupManager.removePowerups((p) -> return p == bullet)
							bullet\remove()
							bullet\destroy()
							bullet\execute(@wrestler)

				when levelState.LEVEL_LOST
					@wrestler\removeIcon()
					@ufo\doAction("crash")
					@wrestler\doAction("idle")
					@running = false
					performWithDelay(4, ->
						@pause!
						screenManager.openScreen("mainMenu"))

		
			coroutine.yield()
	
	pause: () =>
		@oldRoot = MOAIActionMgr.getRoot()
		MOAIActionMgr.setRoot()

	close: () =>
		@running = false
		@thread = nil
		@ground = nil
		@wrestler = nil
		@startX = nil
		@indicator = nil
		@length = nil
		MOAIActionMgr.setRoot(@oldRoot)
		@oldRoot = nil
		@world = nil

	win: () =>
		if @state == levelState.RUNNING
			@state = levelState.LEVEL_WON
			@pause!
			-- Add win graphic
			prop = MOAIProp2D.new()
			prop\setLoc(0, 0)
			prop\setColor 1.0, 1.0, 1.0, 1.0
			prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
			clickable = true

			-- @rectangle\wndToWorld!
			rectangle = Rectangle( -128, -32, 128, 32 )

			gfxQuad = MOAIGfxQuad2D.new()
			gfxQuad\setTexture( R.ASSETS.TEXTURES.WIN_GAME )
			gfxQuad\setRect( rectangle\get() )

			prop\setDeck( gfxQuad )

			LayerMgr\getLayer("ui")\insertProp prop
			buttonManager.forcefullyDisableButtons!

			print "CURRENT LEVEL: #{@levelNO}"

			if saveFile.Save.CURRENT_LEVEL <= @levelNO
				saveFile.Save.CURRENT_LEVEL = @levelNO + 1
				save()
				print "CURRENT LEVEL SAVEs: #{@levelNO}"

			performWithDelay(2, -> screenManager.openScreen("mainMenu"))

			
		
	gameOver: () =>
		if @state == levelState.RUNNING
			@state = levelState.LEVEL_LOST
			characterManager.removeAndDestroyCharacters((char) -> char.name == 'unit')
			powerupManager.removeAndDestroyAllPowerups!
			Pntr\setWorld(@world)
	    -- Add gameover graphic
	    prop = MOAIProp2D.new()
	    prop\setLoc(0, 0)
	    prop\setColor 1.0, 1.0, 1.0, 1.0
	    prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
	    clickable = true

	    -- @rectangle\wndToWorld!
	    rectangle = Rectangle( -128, -32, 128, 32 )

	    gfxQuad = MOAIGfxQuad2D.new()
	    gfxQuad\setTexture( R.ASSETS.TEXTURES.GAME_OVER )
	    gfxQuad\setRect( rectangle\get() )

	    prop\setDeck( gfxQuad )

	    LayerMgr\getLayer("ui")\insertProp prop
	    buttonManager.forcefullyDisableButtons!