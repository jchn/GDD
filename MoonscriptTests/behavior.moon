--
-- ABSTRACT BEHAVIOR CLASS
--

class AbstractBehavior
	new: (@character) =>
		print "Behavior Initialized"
		print @character

	execute: (otherCharacters) =>
		-- Executes the behavior
		print "Behavior Executing"

	printInfo: =>
		print "Behavior class"

--
-- BEHAVIOR CLASSES
--

export class NullBehavior extends AbstractBehavior
	printInfo: =>
		print "Null Behavior"

export class WalkBehavior extends AbstractBehavior
	printInfo: =>
		print "Walk Behavior"

	execute: (otherCharacters) =>
		super
		@character\move(10, 0, gameSpeed)

export class PunchBehavior extends AbstractBehavior
	printInfo: =>
		print "Punch Behavior"

	execute: (otherCharacters) =>
		for char in *otherCharacters do
			char\alterHealth(-2)

export class KickBehavior extends AbstractBehavior
	printInfo: =>
		print "Kick Behavior"