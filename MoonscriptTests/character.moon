--
-- CHARACTER CLASS
--

export class Character
	new: (@prop, @health, @direction) =>
		@alive = true
		print "Character Initialized"
		@behaviors = {}

	alterHealth: (deltaHealth) =>
		@health += deltaHealth

	die: =>
		print "Character Died"
		@alive = false
		@health = 0

	addBehavior: (behaviorID) =>
		print "Character: " .. behaviorID
		behavior = behaviorFactory.getBehavior(behaviorID, @)
		table.insert(@behaviors, behavior)

	printBehaviors: =>
		print "Character Behaviors"
		for behavior in *@behaviors do
			behavior.printInfo()

	update: =>
		for behavior in *@behaviors do
			behavior\execute(getOtherCharacters(@))

		if @health <= 0 and @alive
			@die()

	addToLayer: (@layer) =>
		print @prop
		print "Adding to layer"
		@layer\insertProp(@prop)

	removeFromLayer: =>
		@layer\removeProp(@prop)

	move: (deltaX, deltaY, speed) =>
		@prop\moveLoc(deltaX * @direction, deltaY, speed)

--
-- HERO CLASS
--

export class Hero extends Character

--
-- ENEMY CLASS
--

export class Enemy extends Character

	die: =>
		@removeFromLayer()
		super
		removeCharacter(@)

--
-- UFO CLASS
--

export class UFO extends Character

	die: =>
		super
		pause()