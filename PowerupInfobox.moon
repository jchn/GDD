export class PowerupInfobox
	new: (@texture, @imageRectangle, @text, @textboxRectangle, @style, @layer,  @x, @y, @type) =>
		@prop = MOAIProp2D.new()
		@prop\setColor 1.0, 1.0, 1.0, 1.0
		@prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)
		@prop.clickable = true
		@prop.parent = @

		@gfxQuad = MOAIGfxQuad2D.new()
		@gfxQuad\setTexture(@texture)
		@gfxQuad\setRect(@imageRectangle\get())

		@textbox = MOAITextBox.new()
		@textbox\setStyle(@style)
		@textbox\setString(@text)
		@textbox\setRect(@textboxRectangle\get())
		@textbox\setYFlip(true)
		@textbox\setAlignment ( MOAITextBox.LEFT_JUSTIFY)
		@textbox.clickable = true
		@textbox.parent = @

		@prop\setDeck(@gfxQuad)

		@setLoc(@x, @y)

	setLoc: (@x, @y) =>
		@prop\setLoc(@x, @y)
		@textbox\setLoc(@x + (@imageRectangle\getWidth()/2) + 5, @y - (@textboxRectangle\getHeight()/2))

	triggerClick: (x, y) =>
		x, y = @layer\worldToWnd x, y
		if characterManager.powerupInCollection(@type) and screenManager.levelRunning!
			characterManager.useCollectedPowerup(@type)

			characterLayer = LayerMgr\getLayer("characters")
			x, y = characterLayer\wndToWorld x, y
			characterLayer.x, characterLayer.y = x, y
			powerup = powerupManager.makePowerup(@type, x, y)
			Pntr\forcedPick(powerup.prop, characterLayer)

	add: () =>
		@layer\insertProp(@prop)
		@layer\insertProp(@textbox)

	remove: () =>
		@layer\removeProp(@prop)
		@layer\removeProp(@textbox)

	setText: (@text) =>
		@textbox\setString(@text)

export class UnitInfo

	new: (@layer, texture, textureRectangle, textboxRectangle, @unitInfo) =>
		imageQuad = MOAIGfxQuad2D.new()
		imageQuad\setTexture( texture )
		imageQuad\setRect( textureRectangle\get! )

		@prop = MOAIProp2D.new()
		@prop\setDeck( imageQuad )

		@textbox = MOAITextBox.new()
		@textbox\setStyle(R.STYLE)
		@textbox\setString(@unitInfo.TEXT_ENTRY)
		@textbox\setRect(textboxRectangle\get())
		@textbox\setYFlip(true)
		@textbox\setAlignment( MOAITextBox.CENTER_JUSTIFY)

		@height = textureRectangle\getHeight!
		@width = textureRectangle\getWidth!

		@powerupCounters = {}

		for powerUpID, amount in pairs @unitInfo.COST do
			x, y = 0, 0
			graphic = powerupManager.getGraphic(powerUpID)
			powerupInfobox = PowerupInfobox(graphic, Rectangle(-16, -16, 16, 16), "#{amount}", Rectangle(0, 0, 30, 25), R.ASSETS.STYLES.ARIAL, LayerMgr\getLayer("pausemenu"), x, y, powerUpID)
			table.insert(@powerupCounters, powerupInfobox)
		
	add: () =>
		@layer\insertProp @prop
		@layer\insertProp @textbox
		for powerupCounter in *@powerupCounters do
			powerupCounter\add()

	remove: () =>
		@layer\removeProp @prop
		@layer\removeProp @textbox
		for powerupCounter in *@powerupCounters do
			powerupCounter\remove()

	setLoc: (x, y) =>
		@prop\setLoc(x, y + (@height/2))
		@textbox\setLoc(x, y - (@height/2))
		for powerupCounter in *@powerupCounters do
			powerupCounter\setLoc(x, y + 18)
