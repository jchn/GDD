export class Rotator

	new: (@NumberOfVisibleElements, @x, @y, @rectangle, @xOffset, @yOffset, @orientation) =>
		@elements = {}
		@currentIndex = 1

	addElement: (element) =>
		@elements[#@elements + 1 ] = element

	gotoElement: (@currentIndex) =>
		@showElements()

	showNext: () =>
		@currentIndex += 1
		@showElements()

	showPrevious: () =>
		@currentIndex -= 1
		@showElements()

	showElements: () =>
		startingIndex = @currentIndex

		@remove!

		elementsToEitherSide = math.floor(@NumberOfVisibleElements / 2)

		initialX, initialY = @x, @y

		if @orientation = orientation.HORIZONTAL
			initialX = @x - (elementsToEitherSide * (@rectangle\getWidth! + @xOffset))
			if @NumberOfVisibleElements % 2 == 0
				initialX += ((@rectangle\getWidth! + @xOffset) / 2)
			initialY = @y
		else
			initialX = @x
			initialY = @y - (elementsToEitherSide * (@rectangle\getHeight! + @yOffset))
			if @NumberOfVisibleElements % 2 == 0
				initialY += ((@rectangle\getHeight! + @yOffset) / 2)

		for i = 0, @NumberOfVisibleElements - 1
			tempIndex = (startingIndex + i)

			index = ((tempIndex - 1) % (#@elements)) + 1

			x, y = initialX, initialY

			if @orientation = orientation.HORIZONTAL
				x = initialX + (@rectangle\getWidth! + @xOffset) * i
				y = initialY
			else
				x = initialX
				y = initialY + (@rectangle\getHeight! + @yOffset) * i

			@elements[index]\setLoc(x,y)
			@elements[index]\add()
			@currentIndex = index

	add: () =>
		@showElements(@currentIndex)

	remove: () =>
		for element in *@elements do
			element\remove!
			
			


