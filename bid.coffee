class Robot
	constructor: ->
		@deck = new Deck()
		@hands = []
	
	gimmeCards: ->
		# shuffle deck with Fisher-Yates
		# http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
		@hands = @deck.gimmeHands()
		@prettyPrintHands()

	whatsMyHand: ->
		@toStringOneHand(@hands.north)

	prettyPrintHands: ->
		console.log "north: " + @toStringOneHand(@hands.north)
		console.log "south: " + @toStringOneHand(@hands.south)
		console.log "east: " + @toStringOneHand(@hands.east)
		console.log "west: " + @toStringOneHand(@hands.west)

	toStringOneHand: (hand) ->
		sorted = [[],[],[],[]]

		for card in hand
			sorted[card.suit].push(card.value)

		whatDoIHave = ""
		for s in [0..3]
			whatDoIHave += @deck.suitsNames[s]
			for c in sorted[s]
				whatDoIHave += @deck.facesNames[c] + " "
			whatDoIHave += "\t"
		whatDoIHave

class Deck
	constructor: ->
		@suits = [0..3] 
		@faces = [0..12] 
		@suitsNames = ["♠", "♥", "♦", "♣"] 
		@facesNames = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

		@unshuffled = []
		for suit in @suits
			for face in @faces
				@unshuffled.push {value: face, suit: suit}

	gimmeHands: ->
		shuffledDeck = @shuffle()
		console.log shuffledDeck
		hands = {}
		hands.north = (@unshuffled[i] for i in shuffledDeck[0..12])[0..12]
		hands.east  = (@unshuffled[j] for j in shuffledDeck[13..25])[0..12]
		hands.south = (@unshuffled[i] for i in shuffledDeck[26..38])[0..12]
		hands.west  = (@unshuffled[i] for i in shuffledDeck[39..51])[0..12]
		hands		

	shuffle: ->
		shuffledDeck = [0..51]
		i = shuffledDeck.length
		while --i
				j = Math.floor(Math.random() * (i+1))
				[shuffledDeck[i], shuffledDeck[j]] = [shuffledDeck[j], shuffledDeck[i]]
		shuffledDeck

window.Robot = Robot
window.Deck = Deck


