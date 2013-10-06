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
require 'eventhandler'
require 'datatracker'

require 'lib/copy'
export _ = require 'lib/underscore'

export mouseX = 0
export mouseY = 0

export entityCategory = {
  BOUNDARY: 0x0001
  CHARACTER: 0x0002
  POWERUP: 0x0004
  INACTIVEPOWERUP: 0x0010
  DRAGGEDPOWERUP: 0x0100
  BULLET: 0x1000
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

CONFIG_FILE = 'config/config.json'
SAVE_FILE = (MOAIEnvironment.documentDirectory or "./") .. '/config/save.json'

dataBuffer = MOAIDataBuffer.new()
dataBuffer\load(CONFIG_FILE)
config = dataBuffer\getString()
configTable = MOAIJsonParser.decode config
configTable = configTable.Config

saveBuffer = MOAIDataBuffer.new()
saveBuffer\load(SAVE_FILE)
saveString = saveBuffer\getString()
export saveFile = MOAIJsonParser.decode saveString

export save = () =>
  saveString = MOAIJsonParser.encode saveFile
  saveBuffer\setString(saveString)
  saveBuffer\save(SAVE_FILE)

export resetSave = () =>
  saveFile = {}
  saveFile.Save = {}
  saveFile.Save.CURRENT_LEVEL = 1
  save()

if saveFile == nil
  resetSave()

characterManager.setConfigTable(configTable.Characters)

for screen in *configTable.Screens do
  screenType = screen.TYPE\lower!
  newScreen = nil
  switch screenType
    when "level"
      newScreen = Level("config/" .. screen.FILE, screen.LEVEL_NO)
    when "tutlevel"
      newScreen = Level("config/" .. screen.FILE, screen.LEVEL_NO)
    else
      newScreen = GameScreen("config/" .. screen.FILE)
  screenManager.registerScreen(screen.NAME, newScreen)
  if screen.DEFAULTOPEN
    screenManager.openScreen(screen.NAME)

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
