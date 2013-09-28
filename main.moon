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
require 'PowerupInfobox'
require 'floatingnumber'
require 'assetLoader'
require 'indicator'
require 'level'

export _ = require 'lib/underscore'

export mouseX = 0
export mouseY = 0

export entityCategory = {
  BOUNDARY: 0x0001,
  CHARACTER: 0x0002,
  POWERUP: 0x0004
  INACTIVEPOWERUP: 0x0010
}

-- Openen window
screenWidth = R.DEVICE_WIDTH
screenHeight = R.DEVICE_HEIGHT
MOAISim.openWindow "wrestlers vs aliens", screenWidth, screenHeight
R\load()

level = Level('config/level1.json')
level\load(-> print 'done loading')
level\initialize()
level\start()


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
