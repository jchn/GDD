io.stdout\setvbuf("no")
require 'resource'
require 'rectangle'
require 'healthbar'
require 'character'
require 'action'
require 'powerup'
require 'pointer'
require 'ai'
require 'simplebutton'
require 'layermanager'
require 'powerupInfobox'
require 'floatingnumber'
require 'assetLoader'
require 'indicator'
require 'screens'

export _ = require 'lib/underscore'

export mouseX = 0
export mouseY = 0

export entityCategory = {
  BOUNDARY: 0x0001
  CHARACTER: 0x0002
  POWERUP: 0x0004
  INACTIVEPOWERUP: 0x0010
  DRAGGEDPOWERUP: 0x0100
}

export direction = {
  LEFT: -1,
  RIGHT: 1
}

export splitAtSpaces = (string) ->
  words = {}
  for word in string\gmatch("%S+") do
    table.insert(words, word)
  return words

-- Openen window
screenWidth = R.DEVICE_WIDTH
screenHeight = R.DEVICE_HEIGHT
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()

dataBuffer = MOAIDataBuffer.new()
dataBuffer\load('config/config.json')
config = dataBuffer\getString()
configTable = MOAIJsonParser.decode config
configTable = configTable.Config

-- screenToOpen = ""

-- for screen in *configTable.Screens do
--   print "Making screen #{screen.NAME} from config.json"
--   screenType = screen.TYPE\lower!
--   newScreen = nil
--   switch screenType
--     when "Level"
--       newScreen = Level(screen.FILE)
--     else
--       newScreen = GameScreen(screen.FILE)
--   screenManager.registerScreen(screen.NAME, newScreen)
--   if screen.DEFAULTOPEN == true
--     screenToOpen = screen.NAME

-- screenManager.openScreen(screenToOpen)


mainMenu = GameScreen('config/mainmenu.json')
screenManager.registerScreen("mainMenu", mainMenu)

level = TutLevel('config/level1.json')

screenManager.registerScreen("level_1", level)

level = Level('config/level2.json')
screenManager.registerScreen("level_2", level)

level = Level('config/level3.json')
screenManager.registerScreen("level_3", level)

screenManager.openScreen("mainMenu")

export performWithDelay = (delay, func, repeats, ...) ->
  t = MOAITimer.new()
  t\setSpan delay
  t\setListener(MOAITimer.EVENT_TIMER_END_SPAN, ->
    t\stop()
    t = nil
    func(unpack(arg))
    if repeats
      if repeats > 1
        performWithDelay( delay, func, repeats - 1, unpack( arg ) )
      elseif repeats == 0
        performWithDelay( delay, func, 0, unpack( arg ) ))
  t\start()
