class Animation
  new: (@character, config, @callback = ->) =>
      texture = R.WRESTLER_IDLE -- from config

      rect = Rectangle -32, -32, 32, 32 -- from config

      @tileLib = MOAITileDeck2D\new()
      @tileLib\setTexture(texture)
      @tileLib\setSize(2, 1) -- from config
      @tileLib\setRect(rect\get())

      @character.prop\setDeck @tileLib

      @curve = MOAIAnimCurve.new()
      @curve\reserveKeys(2) -- from config

      @curve\setKey(1, 0.25, 1) -- from config
      @curve\setKey(2, 0.5, 2) -- from config

      @anim = MOAIAnim\new()
      @anim\reserveLinks(1) -- from config
      @anim\setLink(1, @curve, @character.prop, MOAIProp2D.ATTR_INDEX)
      @anim\setMode(MOAITimer.LOOP)
      @anim\setListener(MOAITimer.EVENT_TIMER_END_SPAN, @\callback)
      @anim\setSpan(1)

  init: () ->

  start: =>
    @anim\start()