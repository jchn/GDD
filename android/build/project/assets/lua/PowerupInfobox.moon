export class PowerupInfobox
	new: (@texture, @imageRectangle, @text, @textboxRectangle, @style, @layer,  @x, @y) =>
		@prop = MOAIProp2D.new()
		@prop\setLoc(@x, @y)
		@prop\setColor 1.0, 1.0, 1.0, 1.0
		@prop\setBlendMode(MOAIProp2D.GL_SRC_ALPHA, MOAIProp2D.GL_ONE_MINUS_SRC_ALPHA)

		@gfxQuad = MOAIGfxQuad2D.new()
		@gfxQuad\setTexture(@texture)
		@gfxQuad\setRect(@imageRectangle\get())

		@textbox = MOAITextBox.new()
		@textbox\setStyle(@style)
		@textbox\setString(@text)
		@textbox\setRect(@textboxRectangle\get())
		@textbox\setYFlip(true)
		@textbox\setLoc(@x + (@imageRectangle\getWidth()/2) + 5, @y - (@textboxRectangle\getHeight()/2))
		@textbox\setAlignment ( MOAITextBox.LEFT_JUSTIFY)

		print "Width of image: #{@imageRectangle\getWidth()}"

		@prop\setDeck(@gfxQuad)
		@add()

	add: () =>
		@layer\insertProp(@prop)
		@layer\insertProp(@textbox)

	remove: () =>
		@layer\removeProp(@prop)
		@layer\removeProp(@textbox)

	setText: (@text) =>
		@textbox\setString(@text)