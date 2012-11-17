class Deck
	constructor: ->
		# whooole bunch of constants
		@suits = [0..3] 
		@values = [0..12] 
		@sides = ["north", "south", "east", "west"]		
		@suitSymbols = ["♣", "♦", "♥", "♠"] 
		@suitNames = ["clubs", "diamonds", "hearts", "spades"]		
		@valueNames = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
		@points = [4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]

		@unshuffled = []
		for suit in @suits
			for value in @values
				@unshuffled.push {value: value, suit: suit}

	# shuffle deck with Fisher-Yates
	# http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	shuffle: ->
		shuffledDeck = [0..51]
		i = shuffledDeck.length
		while --i
				j = Math.floor(Math.random() * (i+1))
				[shuffledDeck[i], shuffledDeck[j]] = [shuffledDeck[j], shuffledDeck[i]]
		shuffledDeck

	gimmeHands: ->
		shuffledDeck = @shuffle()
		rawHands = {}

		# deal 13 cards to each side
		startIndex = 0
		for side in @sides
			rawHands[side] = (@unshuffled[i] for i in shuffledDeck[startIndex..startIndex+12])[0..12]
			startIndex += 13

		# now break each hand nicelyinto suits, and sort the values
		niceHands = {}
		for side in @sides
			niceHands[side] = @sortBySuits(rawHands[side])
		
		niceHands

	sortBySuits: (hand) ->
		sortedHand = {clubs:[], diamonds:[], hearts:[], spades:[]}

		for card in hand
			sortedHand[@suitNames[card.suit]].push(card.value)

		# sort the values within each suit
		for i in @suits
			values = sortedHand[@suitNames[i]]
			sortedHand[@suitNames[i]] = values.sort( (a,b) => 
					# ace needs to win
					if a == 0 then 1 
					else if b == 0 then -1
					else parseInt(a) - parseInt(b))

		sortedHand


	scoreIt: (hand) ->
		points = 0
		for suit in @suitNames
			for card in hand[suit]
				points += @points[card]
		points

	isHandBalanced: (hand) ->
		# a balanced hand has no voids, and no singletons, and no 5s
		# for now ill count only 3334 and 3244 as balanced, but not 3235
		counts = [hand.clubs.length, hand.diamonds.length, hand.hearts.length, hand.spades.length]
		numDoubles = 0
		for i in counts
			if i <= 1 || i >= 5
				return false
			if i == 2
				numDoubles += 1

		# at most one doubleton
		if (numDoubles > 2)
			return false

		return true
		
window.Deck = Deck

