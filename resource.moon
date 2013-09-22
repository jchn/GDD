class Resource
  new: () =>
    -- misschien later resources in json file zetten en uitlezen
    @WRESTLER_IDLE = MOAIImage.new()
    @WRESTLER_WALK = MOAIImage.new()
    @MUSHROOM = MOAIImage.new()
    -- databuffer = MOAIDataBuffer.new()
    -- databuffer\load 'animations/test.json'
    -- json = databuffer\getString()
    -- print json
    -- file = MOAIJsonParser.decode json
    -- print file.animation.a

    -- @animations: {
      
    -- }

    @BUTTON = MOAITexture.new()


  load: () =>
    @WRESTLER_IDLE\load('resources/wrestler_idle.png')
    @WRESTLER_WALK\load('resources/wrestler_walk.png')
    @MUSHROOM\load('resources/mushroom.png')

    @BUTTON\load "resources/mushroom.png"

  loadJson: () =>
    @databuffer = MOAIDataBuffer.new()

export R = Resource()