class Thingamadoer
	constructor: ->
		@deck = new Deck()
		@messages = new Messages()

		@bids = {
		baffled: {howMany: -1, suit: -1, text: "no idea"}, 
		pass: {howMany: 0, suit: -1, text: "pass"}, 
		NT1: {howMany: 1, suit: -1, text: "1NT"}, 
		NT2: {howMany: 2, suit: -1, text: "2NT"}, 
		NT3: {howMany: 3, suit: -1, text: "3NT"},
		C1: {howMany: 1, suit: 0, text: "1C"},  
		C2: {howMany: 2, suit: 0, text: "2C"},  
		C3: {howMany: 3, suit: 0, text: "3C"},
		D1: {howMany: 1, suit: 1, text: "1D"}, 
		D2: {howMany: 2, suit: 2, text: "2D"},    
		D3: {howMany: 3, suit: 3, text: "3D"},
		H1: {howMany: 1, suit: 1, text: "1H"},  
		H2: {howMany: 2, suit: 2, text: "2H"},    
		H3: {howMany: 3, suit: 3, text: "3H"},
		S1: {howMany: 1, suit: 1, text: "1S"},  
		S2: {howMany: 2, suit: 2, text: "2S"},    
		S3: {howMany: 3, suit: 3, text: "3S"}
		}

		@setUpClicks()
		@newGame()

	setUpClicks: ->
		$("#deal").click =>
			@newGame()
			@showMeMyHand()
		$("#pointsScore").click =>
			@scoreMyHand()
		$("#pointsWhy").click =>
			$("#pointsDetails").text(@messages.scoring)
		$("#openPass").click =>
			answerBox = $('#openBidAnswer') 
			$('#openBidWhy').show()
			if (@whatShouldIOpenWith().text == "pass")
				answerBox.text(@messages.yay)
			else
				answerBox.text(@messages.nay)	
		$("#openBid").click =>
			answerBox = $('#openBidAnswer') 
			$('#openBidWhy').show()
			youSaid = $('#openHowMuch').val() + $("#openOfWhat").val()
			console.log "you said: " + youSaid
			if (@whatShouldIOpenWith().text == youSaid)
				answerBox.text(@messages.yay)
			else
				answerBox.text(@messages.nay)	
		$("#openBidWhy").click =>
			$("#openBidDetails").text(@messages.openingBid)	

	newGame: ->
		@hands = @deck.gimmeHands()
		@myHand = @hands.north
		@myHandIsWorth = @scoreIt(@myHand)
		console.log "---- NEW GAME ----"
		console.log "my hand is worth: " + @myHandIsWorth
		console.log "i should bid: " + @whatShouldIOpenWith().text

	showMeMyHand: ->
		for suit in @deck.suitNames
			prettifiedHand = ""
			for card in @myHand[suit]
				prettifiedHand += @deck.valueNames[card] + " "
			$("##{suit}").text(prettifiedHand)    

	scoreIt: (hand) ->
		# Ace = 4 pts.     King = 3 pts.     Queen = 2 pts.     Jack = 1 pt
		points = 0
		for suit in @deck.suitNames
			for card in hand[suit]
				points += @deck.points[card]
		points

	scoreMyHand: () ->
		answerBox = $('#pointsAnswer') 
		$('#pointsWhy').show()

		if (parseInt($('#points').val()) != @myHandIsWorth)
			answerBox.text(@messages.nay)
		else
			answerBox.text(@messages.yay)

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

	whatShouldIOpenWith: () ->
		myHandIsBalanced = @isHandBalanced(@myHand)
		if @myHandIsWorth < 13
			return @bids.pass
		else if @myHandIsWorth >= 15 && @myHandIsWorth <= 17 && myHandIsBalanced
			return @bids.NT1
		else if @myHandIsWorth >= 20 && @myHandIsWorth <= 22 && myHandIsBalanced
			return @bids.NT2
		else if @myHandIsWorth >= 25 && @myHandIsWorth <= 27 && myHandIsBalanced
			return @bids.NT3
		else if @myHandIsWorth >= 22 && !myHandIsBalanced
			return @bids.C2
		else if @myHandIsWorth >= 13 && @myHandIsWorth <= 21
			# pick longest major
			if (@myHand.hearts.length >= 5 && @myHand.spades.length >= 5)
				if (@myHand.hearts.length >= @myHand.spades.length) 
					return @bids.H1 
				else 
					return @bids.S1
			else if @myHand.hearts.length >= 5
				return @bids.H1
			else if @myHand.spades.length >= 5
				return @bids.S1
			# pick longest minor else keep bidding low
			if (@myHand.clubs.length >= 3 && @myHand.diamonds.length >= 3)
				if (@myHand.clubs.length >= @myHand.diamonds.length) 
					return @bids.C1 
				else 
					return @bids.D1
			else if @myHand.clubs.length >= 3
				return @bids.C1
			else if @myHand.diamonds.length >= 3
				return @bids.D1
		else if @myHandIsWorth >= 21 # strong 2x bid. Panic for now
			return @bids.baffled 
		else
			return @bids.baffled 
		
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

class Messages
	constructor: ->
		@yay = "Bingo, bango!"
		@nay = "That's not right. Try again!"
		@scoring = "Aces = 4 pts, Kings = 3 pts, Queens = 2 pts, and Jacks = 1 pt. Everything else is useless."
		@openingBid = "If you have less than 13 points, pass. Otherwise..."

window.Thingamadoer = Thingamadoer
window.Deck = Deck



