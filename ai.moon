class AI

	-- Bepaalt welke action het gunstigts is om uit te voeren voor de target character
	think: (character) ->

		-- Checkt of de target character de IDLE state heeft
		if character.state == Characterstate.IDLE

			-- Lege tabel om de mogelijke opties op te slaan a.d.v. een score als key
			options = {}
			
			-- Loop door alle action objecten die de target character hee
			for actionID, possibleAction in pairs character.actions do
				-- Able: of de actie überhaupt uitgevoerd kan worden door de target character
				-- Score: elke actie bepaalt zelf hoe nuttig die actie is in een bepaalde vooraf afgesproken metric
				able, score = possibleAction\poll()
				if able
					-- Sla de acties op in de table met hun score als key
					-- Nadeel: als twee acties dezelfde score hebben, dan overschrijft de laatste de eerdere
					options[score] = possibleAction

			-- Geef de action met de hogste score terug, zodat de target character die actie uit kan gaan voeren
			selectedOption = options[table.maxn(options)]

			return true, selectedOption

		return false, nil

export ai = AI()
