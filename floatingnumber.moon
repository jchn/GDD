export class FloatingNumber
	new: (@text, @rectangle, @style, @length, @x, @y) =>
		@textbox = MOAITextBox.new()
		@textbox\setStyle(@style)
		@textbox\setString(@text)
		@textbox\setRect(@rectangle\get())
		@textbox\setYFlip(true)
		@textbox\setLoc(@x, @y)
		@textbox\setAlignment ( MOAITextBox.LEFT_JUSTIFY)

		@textbox\moveLoc(0, 150, 0, @length)
		@textbox\moveColor(1, 1, 1, 0, @length)

        @layer = LayerMgr\getLayer("characters")
        @layer\insertProp @textbox

    destroy: () =>
    	@layer\removeProp @textbox