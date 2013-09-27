class GameManager

	screens = {}
	levels = {}
	currentScreen = nil
	currentLevel = nil
	registerScreen: (screenID, screen) ->
		screens[screenID] = screen

	registerLevel: (levelID, level) ->
		levels[levelID] = level

	closePrevious: () ->
		if currentScreen != nil
			currentScreen\close!
			currentScreen = nil
		if currentLevel != nil
			currentLevel\close!
			currentLevel = nil
		clearPointer()

	openScreen: (screenID) ->
		gameManager.closePrevious()
		currentScreen = screens[screenID]
		currentScreen\load(-> print 'done loading')
		currentScreen\open!

	openLevel: (levelID) ->
		gameManager.closePrevious()
		currentLevel = levels[levelID]
		currentLevel\load(-> print 'done loading')
		currentLevel\initialize()
		currentLevel\start()

export gameManager = GameManager()