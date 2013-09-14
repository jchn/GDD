--
-- BEHAVIOR CLASS FACTORY
--

class BehaviorFactory
	getBehavior: (behaviorID = "", character) ->
		behaviorID = behaviorID\lower()
		print "Factory: " .. behaviorID

		switch behaviorID
			when "walk"
				print "Walk Behavior"
				return WalkBehavior(character)

			when "punch"
				print "Punch Behavior"
				return PunchBehavior(character)

			when "kick"
				print "Kick Behavior"
				return KickBehavior(character)

			else
				print "Null Behavior"
				return NullBehavior(character)

export behaviorFactory = BehaviorFactory()

--
-- CHARACTER CLASS FACTORY
--

class CharacterFactory
	getCharacter: (characterID = "", health = 0, x = 0, y = 0, direction = direction.LEFT) ->
		characterID = characterID\lower()
		print "Factory: " .. characterID

		prop = MOAIProp2D.new()
		prop\setLoc(x, y)

		switch characterID
			when "hero"
				print "Hero Character"
				prop\setDeck(heroDeck)
				return Hero(prop, health, direction)

			when "enemy"
				print "Enemy Character"
				prop\setDeck(alienDeck)
				return Enemy(prop, health, direction)

			when "ufo"
				print "UFO Character"
				prop\setDeck(ufoDeck)
				return UFO(prop, health, direction)

			else
				print "Generic Character"
				prop\setDeck(heroDeck)
				return Character(prop, health, direction)



export characterFactory = CharacterFactory()
