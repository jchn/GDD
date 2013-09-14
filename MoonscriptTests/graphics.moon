alienTexture = MOAIImage.new()
alienTexture\load("resources/graphics/alien.png")

export alienDeck = MOAIGfxQuad2D.new()
alienDeck\setTexture(alienTexture)
alienDeck\setRect(-64,-64,64,64)

heroTexture = MOAIImage.new()
heroTexture\load("resources/graphics/hero.png")

export heroDeck = MOAIGfxQuad2D.new()
heroDeck\setTexture(heroTexture)
heroDeck\setRect(-64,-64,64,64)

ufoTexture = MOAIImage.new()
ufoTexture\load("resources/graphics/ufo.png")

export ufoDeck = MOAIGfxQuad2D.new()
ufoDeck\setTexture(ufoTexture)
ufoDeck\setRect(-64,-64,64,64)