class Resource
  new: () =>
    -- misschien later resources in json file zetten en uitlezen
    @WRESTLER_IDLE = MOAIImage.new()
    @WRESTLER_WALK = MOAIImage.new()
    @MUSHROOM = MOAIImage.new()
  load: () =>
    @WRESTLER_IDLE\load('resources/wrestler_idle.png')
    @WRESTLER_WALK\load('resources/wrestler_walk.png')
    @MUSHROOM\load('resources/mushroom.png')

export R = Resource()