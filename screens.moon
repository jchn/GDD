class ScreenManager

	screens = {}
	currentScreen = nil

	EVENTS = {
		IDLE: 0,
		LEVEL_START: 1,
		LEVEL_END: 2,
		GIVE_POWERUP_TO_PYGO: 3,
		GIVE_POWERUP_TO_ENEMY: 4,
		GIVE_POWERUP_TO_UNIT: 5,
		GET_POWERUP_FROM_UI: 6,
		UNIT_DIES: 7
	}
	previousScreenID = ""

	levelRunning: () ->
		return currentScreen.running

	registerScreen: (screenID, screen) ->
		screens[screenID] = screen

	openPrevious: () ->
		print "Previous screen: #{previousScreenID}"
		if screenManager.hasPreviousScreen!
			screenManager.openScreen(currentScreen.previousScreenID)

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
		currentScreen.screenID = screenID

	hasPreviousScreen: () ->
		print "Has previous screen: #{currentScreen.previousScreenID}"
		return (currentScreen.previousScreenID != "" and currentScreen.previousScreenID != nil)

	makeScreenElement: (layer, screenElementConfig, secondaryLayer = layer) ->
		elementID = screenElementConfig.ELEMENT\lower!
		switch elementID
			when "button"
				size = screenElementConfig.SIZE
				
				button = SimpleButton(layer, R.ASSETS.IMAGES[screenElementConfig.IMAGE], Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X, screenElementConfig.Y, (-> screenManager.doScreenElementFunctions(screenElementConfig.FUNCTION)), (-> screenManager.doScreenElementFunctions(screenElementConfig.ENABLE_FUNCTION)) )
				return button, elementID
			when "textbutton"
				size = screenElementConfig.SIZE
				
				button =  TextButton(layer, secondaryLayer, R.ASSETS.IMAGES[screenElementConfig.IMAGE], screenElementConfig.TEXT, R.STYLE, Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X, screenElementConfig.Y, (-> screenManager.doScreenElementFunctions(screenElementConfig.FUNCTION)), (-> screenManager.doScreenElementFunctions(screenElementConfig.ENABLE_FUNCTION)) )
				return button, elementID
			when "imagebutton"
				size = screenElementConfig.SIZE
				
				button =  ImageButton(layer, R.ASSETS.IMAGES[screenElementConfig.IMAGE], R.ASSETS.IMAGES[screenElementConfig.BACKGROUND], Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X, screenElementConfig.Y, (-> screenManager.doScreenElementFunctions(screenElementConfig.FUNCTION)), (-> screenManager.doScreenElementFunctions(screenElementConfig.ENABLE_FUNCTION)) )
				return button, elementID
			when "rotator"
				size = screenElementConfig.SIZE

				rotator = Rotator(screenElementConfig.VISIBLE_ELEMENTS, screenElementConfig.X, screenElementConfig.Y, Rectangle(size[1], size[2], size[3], size[4]), screenElementConfig.X_OFFSET, screenElementConfig.Y_OFFSET, orientation.HORIZONTAL)
				for rotatorElement in *screenElementConfig.ELEMENTS do
					element = screenManager.makeScreenElement(layer, rotatorElement)
					rotator\addElement(element)
				return rotator, elementID

	doScreenElementFunctions: (functionInfo) ->

		functionInfo = _.to_array(string.gmatch(functionInfo, "%S+"))
		functionInfo[1] = functionInfo[1]\lower!

		switch functionInfo[1]
			when "openscreen"
				screenManager.openScreen(functionInfo[2])
			when "levelunlocked"
				saveFile.Save.CURRENT_LEVEL >= tonumber(functionInfo[2])
			when "spawnedunits"
				#saveFile.Save.SPAWNED_UNITS >= tonumber(functionInfo[2])
			when "rotatorshownext"
				currentScreen.rotator\showNext()
			when "rotatorshowprevious"
				currentScreen.rotator\showPrevious()
			when "true"
				return true
			when "false"
				return false

export screenManager = ScreenManager()

class Screen

	new: (@configJson, @previousScreenID) =>

	load: (onComplete = -> ) =>
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

	openOverlay: (overlay) =>
		@pause!

		layer = LayerMgr\getLayer 'powerups'
		olayer = LayerMgr\getLayer("overlay")
		ilayer = LayerMgr\getLayer("indicator")
		infoLayer = LayerMgr\getLayer("info")

		texture = MOAIGfxQuad2D.new()
		texture\setTexture R.ASSETS.IMAGES.BLACK
		texture\setRect -1024, -1024, 1024, 1024

		@pausemenuBackground = MOAIProp2D.new()
		@pausemenuBackground\setDeck texture
		@pausemenuBackground\setLoc(0, 0)
		@pausemenuBackground\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
		@pausemenuBackground\setColor 1, 1, 1, 0.6

		olayer\insertProp(@pausemenuBackground)

		imageQuad = MOAIGfxQuad2D.new()
		imageQuad\setTexture( overlay.TEXTURE )
		imageQuad\setRect( -64, -64, 64, 64 )

		imageBg = MOAIProp2D.new()
		imageBg\setDeck( imageQuad )
		imageBg\setLoc(0, 0)
		

		textbox = MOAITextBox.new!
		textbox\setStyle(R.ASSETS.STYLES.ARIAL)
		textbox\setString(overlay.TEXT)
		textbox\setTextSize(20)
		textbox\setLoc(0, -100)
		textbox\setYFlip(true)
		textbox\setRect(-128, -128, 128, 128)
		textbox\setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
		textbox\spool!
		
		infoLayer\insertProp(imageBg)
		infoLayer\insertProp(textbox)

		txtBtn = SimpleButton(infoLayer, R.ASSETS.IMAGES.TRANSPARENT, Rectangle(-1024, -1024, 1024, 1024), 0, 0, ->
			if textbox\isBusy!
				textbox\setSpeed(10000)
			else
				@closeOverlay(overlay))\add!
		e\triggerEvent("OPEN_#{overlay.ID}")


	closeOverlay: (overlay) =>
		LayerMgr\getLayer("indicator")\clear!
		LayerMgr\getLayer("overlay")\clear!
		LayerMgr\getLayer("info")\clear!
		@resume!
		e\triggerEvent("#{overlay.ID}_CLOSE")
		

export class GameScreen extends Screen

	load: (onComplete = -> ) =>
		super (onComplete)
		@screenElements = @configTable.screenElements
		@background = @configTable.background

	open: () =>
		backgroundLayer = LayerMgr\createLayer('background', 1, false, false)\render!
		screenLayer = LayerMgr\createLayer('screen', 2, true, false)\render!
		secondaryLayer = LayerMgr\createLayer('secondary', 3, false, false)\render!

		MOAIGfxDevice\getFrameBuffer()\setClearColor 0, 0, 1, 1

		bggrid = MOAIGrid.new()
		bggrid\initRectGrid 1, 1, 480, 320
		bggrid\setRow 1, 1
		bggrid\setRepeat(true, true)

		bgdeck = MOAITileDeck2D.new()
		bgdeck\setTexture R.ASSETS.IMAGES[@background]
		bgdeck\setSize 1, 1

		bgprop = MOAIProp2D.new()
		bgprop\setDeck bgdeck
		bgprop\setGrid bggrid
		bgprop\setLoc -240, -160

		backgroundLayer\insertProp bgprop

		print "OPENED SCREEN. PREVIOUS SCREEN #{@previousScreenID}"

		if screenManager.hasPreviousScreen!
			@backButton = SimpleButton LayerMgr\getLayer('screen'), R.ASSETS.TEXTURES.BACK_BUTTON, Rectangle(-64, -64, 64, 64), -200, 140, ( -> 
				print "Open the previos screen!"
				screenManager.openPrevious!)
			@backButton\add()

		for screenElement in *@screenElements
			element, elementID = screenManager.makeScreenElement(screenLayer, screenElement, secondaryLayer)
			element\add()
			if elementID == "rotator"
				@rotator = element
				if screenElement.STARTING_ELEMENT == "lastPlayedLevel"
					@rotator\gotoElement(saveFile.Save.LAST_PLAYED)
				else
					@rotator\gotoElement(tonumber(screenElement.STARTING_ELEMENT))


export levelState = {
	MADE: 0
	LOADED: 1
	RUNNING: 2
	LEVEL_LOST: 3,
	LEVEL_WON: 4
}

export class Level extends Screen

	new: (@configJson, @levelNO, @previousScreenID) =>
		super
		@state = levelState.MADE

	load: (onComplete = -> ) =>
		super (onComplete)
		@length = @configTable.length
		@wrestler = @configTable.wrestler
		@spawnableUnits = @configTable.spawnableUnits
		@startingPowerups = @configTable.startingPowerups

		@state = levelState.LOADED

		@world = MOAIBox2DWorld.new()
		@world\setGravity( 0, -10 )
		@world\setUnitsToMeters( 1/30 )
		@world\start()

		Pntr\setWorld(@world)


	open: () =>

		saveFile.Save.LAST_PLAYED = @levelNO
		save()

		@fuel = @length

		-- Setting events for overlays
		if R.ASSETS.OVERLAYS
			for k,v in pairs(R.ASSETS.OVERLAYS)
				overlayName = k
				e\addEventListener(v["EVENT"], -> @openOverlay(R.ASSETS.OVERLAYS[overlayName]))

		@state = levelState.RUNNING
		LayerMgr\createLayer('background', 1, false)\render!\setParallax 0.5, 1
		LayerMgr\createLayer('ground', 2, false)\render!
		LayerMgr\createLayer('characters', 3, true)\render!
		LayerMgr\createLayer('box2d', 4, false)
		LayerMgr\createLayer('foreground', 5, false)\render!\setParallax 1.5, 1
		LayerMgr\createLayer('powerups', 6, true)\render!
		LayerMgr\createLayer('ui', 7, true, false)\render!
		LayerMgr\createLayer('icon', 8, false, false)\render!

		LayerMgr\createLayer('pausemenu', 9, true, false)\render!
		LayerMgr\createLayer('pausebutton', 10, true, false)\render!

		LayerMgr\createLayer('indicator', 11, true, false)\render!
		LayerMgr\createLayer('overlay', 12, true, false)\render!
		LayerMgr\createLayer('info', 13, true, false)\render!

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

		@rotator = Rotator(1, 0, 0, Rectangle(-32, -32, 32, 32), 0, 0, orientation.VERTICAL)

		buttonX = 200
		buttonXInitial = buttonX
		buttonY = -120
		buttonYOffset = -50
		buttonXOffset = -50
		buttonCount = 0

		for spawnableUnit in *@spawnableUnits 
			button = AnimatedCooldownButton LayerMgr\getLayer("ui"), R.ASSETS.IMAGES.UNIT_BUTTON, R.ASSETS.IMAGES[spawnableUnit .. "_ICON"] ,Rectangle(-32, -32, 32, 32), Rectangle(-8, -8, 8, 8), buttonX, buttonY, (-> characterManager.makeCharacter(spawnableUnit)), (-> return characterManager.checkEnemySpawnable(spawnableUnit))
			button\add()
			buttonX += buttonXOffset
			buttonCount += 1
			if buttonCount % 9 == 0
				buttonX = buttonXInitial
				buttonY += buttonYOffset
			unitInfo = UnitInfo(LayerMgr\getLayer("pausemenu"), R.ASSETS.TEXTURES[spawnableUnit .. "_SINGLE"], Rectangle(-64, -64, 64, 64), Rectangle(-160, -64, 160, 64), characterManager.getConfigTable(spawnableUnit))
			@rotator\addElement(unitInfo)

		@pauseButton = SimpleButton LayerMgr\getLayer("pausebutton"), R.ASSETS.TEXTURES.PAUSE_BUTTON, Rectangle(-32, -32, 32, 32), -200, -140, ( -> @\togglePauseScreen!)
		@pauseButton\add()

		for startingPowerup in *@startingPowerups
			powerupManager.makePowerup(startingPowerup.ID, startingPowerup.X, startingPowerup.Y)\activate!
 
		@paused = false
		@running = true
		@thread = MOAIThread.new()
		@thread\run(@\loop)

		if @length > 0
			@startX = @wrestler.body\getPosition()
			@indicator = Indicator(0, @length, LayerMgr\getLayer("ui"), -170, 150, @\gameOver)
			@indicator\add!

			@fuelTimer = MOAITimer.new()
			@fuelTimer\setSpan(1)
			@fuelTimer\setMode(MOAITimer.LOOP)
			@fuelTimer\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\updatefuelCount)
			@fuelTimer\start()

		performWithDelay(0.2, -> e\triggerEvent("LEVEL_START"))

	togglePauseScreen: () =>
		if @paused
			@resume!

			pauseMenuLayer = LayerMgr\getLayer('pausemenu')
			pauseMenuLayer\removeProp(@pausemenuBackground)
			@backButton\remove()
			@rotator\remove()
			@plusButton\remove()
			@minusButton\remove()
			@backButton = nil
			@pausemenuBackground = nil
		else
			pauseMenuLayer = LayerMgr\getLayer('pausemenu')

			texture = MOAIGfxQuad2D.new()
			texture\setTexture R.ASSETS.IMAGES.BLACK
			texture\setRect -1024, -1024, 1024, 1024

			@pausemenuBackground = MOAIProp2D.new()
			@pausemenuBackground\setDeck texture
			@pausemenuBackground\setLoc(0, 0)
			@pausemenuBackground\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
			@pausemenuBackground\setColor 1, 1, 1, 0.6

			pauseMenuLayer\insertProp(@pausemenuBackground)

			@backButton = SimpleButton pauseMenuLayer, R.ASSETS.TEXTURES.BACK_BUTTON, Rectangle(-64, -64, 64, 64), -200, 140, ( -> screenManager.openPrevious! )
			@backButton\add()

			@plusButton = SimpleButton(LayerMgr\getLayer("pausebutton"), R.ASSETS.IMAGES.PLUS_BUTTON, Rectangle(-32, -32, 32, 32), 0, 140, -> @rotator\showPrevious(), -> true)
			@minusButton = SimpleButton(LayerMgr\getLayer("pausebutton"), R.ASSETS.IMAGES.MINUS_BUTTON, Rectangle(-32, -32, 32, 32), 0, -140, -> @rotator\showNext(), -> true)

			@rotator\add()
			@plusButton\add()
			@minusButton\add()

			@pause!

	updatefuelCount: () =>
		@fuel -= 1
		difference = @length - @fuel
		@indicator\update difference

	loop: () =>
		while @running
			characterManager.updateCharacters()
			switch @state
				when levelState.RUNNING
					
					x = @wrestler.body\getPosition()
					R.CAMERA\setLoc((x + 180))
					@ground\setTransform(x,-80)
					@ufo.body\setTransform((x + 360), -15)
					
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

						screenManager.openScreen("levelSelect"))
		
			coroutine.yield()
	
	pause: () =>
		@paused = true
		e\triggerEvent("LEVEL_PAUSE")
		@oldRoot = MOAIActionMgr.getRoot()
		MOAIActionMgr.setRoot()

	resume: () =>
		@paused = false
		MOAIActionMgr.setRoot(@oldRoot)
		e\triggerEvent("LEVEL_RESUME")

	close: () =>
		dt\reset!
		e\clear!
		if @fuelTimer != nil
			@fuelTimer\stop()
			@fuelTimer = nil
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
			buttonManager.removeButtons()

			if saveFile.Save.CURRENT_LEVEL <= @levelNO
				saveFile.Save.CURRENT_LEVEL = @levelNO + 1
				
			@pauseButton\remove()
			characterManager.saveSpawnedUnits()
			save()
			performWithDelay(2, -> screenManager.openScreen("levelSelect"))
		
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
	    buttonManager.removeButtons()
	    @pauseButton\remove()

export class TutLevel extends Level

	test: =>
		-- e\addEventListener("START_LEVEL", -> @openOverlay(R.ASSETS.OVERLAYS.POWERUP_OVERLAY))

	getFirstPowerup: () ->
		powerups = powerupManager.selectPowerups((p) -> true)
		powerups[1].prop

	open: () =>
		super!
		e\addEventListener("FIRST_ELITE_JUMPWALKER_UNIT_DIED", -> @changeWrestlerActions!)

	changeWrestlerActions: () =>
		@wrestler\addAction("walk")
		@wrestler\addAction("run")

export class SandboxLevel extends Level

	load: (onComplete = -> ) =>
		super (onComplete)
		@spawnableUnits = saveFile.Save.SPAWNED_UNITS