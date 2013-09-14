--
-- AI CLASS
--

class AI

	think: (character, otherCharacters) ->
		print "thinking"
		print character

		actions = {}

		for behavior in *character.behaviors do
			table.insert(actions, behavior)

		return actions

export ai = AI()