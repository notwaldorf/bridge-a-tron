class Thingamadoer
	constructor: ->
		@deck = new Deck()
		@messages = new Messages()
		@hands = @deck.gimmeHands()

		@setUpClicks()
		console.log "my hand is worth: " + @scoreIt(@hands.north)
	setUpClicks: ->
		$("#pointsScore").click =>
			@scoreMyHand()
		$("#pointsWhy").click =>
			$("#pointsDetails").text(@messages.scoring)

	scoreIt: (hand) ->
		# Ace = 4 pts.     King = 3 pts.     Queen = 2 pts.     Jack = 1 pt
		points = 0;
		for suit in @deck.suitNames
			for card in hand[suit]
				points += @deck.points[card]
		points

	showMeMyHand: ->
		for suit in @deck.suitNames
			prettifiedHand = ""
			for card in @hands.north[suit]
				prettifiedHand += @deck.valueNames[card] + " "
			$("##{suit}").text(prettifiedHand)    

	scoreMyHand: () ->
		whatItShouldBe = @scoreIt(@hands.north)
		answerBox = $('#pointsAnswer') 

		if (parseInt($('#points').val()) != whatItShouldBe)
			answerBox.text(@messages.nay)
		else
			answerBox.text(@messages.yay)

		$('#pointsWhy').show();

class Deck
	constructor: ->
		# whooole bunch of constants
		@suits = [0..3] 
		@values = [0..12] 
		@sides = ["north", "south", "east", "west"]		
		@suitSymbols = ["♠", "♥", "♦", "♣"] 
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
			sortedHand[@suitNames[i]] = values.sort( (a,b) => parseInt(a) - parseInt(b) )

		sortedHand

class Messages
	constructor: ->
		@yay = "Bingo, bango!"
		@nay = "That's not right. Try again!"
		@scoring = "Aces are worth 4 points. Kings are 3 points, Queens 2 points and Jacks are 1 point. Everything else is useless."

window.Thingamadoer = Thingamadoer
window.Deck = Deck



