class Robot
	constructor: ->
		@deck = new Deck()
		@hands = []

	gimmeCards: ->
		# shuffle deck with Fisher-Yates
		# http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
		@hands = @deck.gimmeHands()
		console.log("-----  NEW DEAL: -----")
		console.log(@hands)
		console.log("----------------------")

	whatsMyHand: ->
		prettifiedHand = {clubs:"", diamonds:"", hearts:"", spades:""}
		console.log(@hands.north)
		for suit in @deck.suitNames
			for card in @hands.north[suit]
				prettifiedHand[suit] += @deck.valueNames[card] + " "

		prettifiedHand
		
class Deck
	constructor: ->
		# whooole bunch of constants
		@suits = [0..3] 
		@values = [0..12] 
		@sides = ["north", "south", "east", "west"]		
		@suitSymbols = ["♠", "♥", "♦", "♣"] 
		@suitNames = ["clubs", "diamonds", "hearts", "spades"]		
		@valueNames = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

		@unshuffled = []
		for suit in @suits
			for value in @values
				@unshuffled.push {value: value, suit: suit}

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
			sortedHand[@suitNames[i]] = values.sort( (a,b) => parseInt(a) - parseInt(b) )

		sortedHand

	

window.Robot = Robot
window.Deck = Deck


