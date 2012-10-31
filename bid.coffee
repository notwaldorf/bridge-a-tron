class Thingamadoer
	constructor: ->
		@deck = new Deck()
		@messages = new Messages()

		@bids = {
		baffled: {howMany: -1, suit: -1, text: "halp, iz confused."}, 
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

		@myBids = [null, null]
		@juliaBids = [null, null]

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
			@checkMyOpeningBid(true)
		$("#openBid").click =>
			@checkMyOpeningBid(false)			
		$("#openBidWhy").click =>
			$("#openBidDetails").text(@messages.openingBid)	

	newGame: ->
		$('#q2').hide("slow")
		$('#q3').hide("slow")
		$('#q31').hide("slow")
		$('#q4').hide("slow")
		$('#q5').hide("slow")

		@hands = @deck.gimmeHands()
		@myHand = @hands.north
		console.log "---- NEW GAME ----"
		console.log "my hand is worth: " + @scoreIt(@myHand)
		console.log "i should bid: " + @whatShouldIOpenWith().nextState
		console.log "julia's hand is: "
		console.log @hands.south
		console.log "julia's hand is worth: " + @scoreIt(@hands.south)
		#console.log "julia should respond with: " + @whatShouldJuliaRespondWith().text
		
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

		if (parseInt($('#points').val()) != @scoreIt(@myHand))
			answerBox.text(@messages.nay)
		else
			answerBox.text(@messages.yay)
			$('#q2').show("slow")

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

	checkMyOpeningBid: (iPassed) ->
		answerBox = $('#openBidAnswer') 
		$('#openBidWhy').show()
		if iPassed
			youSaid = "bid_pass"
		else
			youSaid = "bid_" + $('#openHowMuch').val() + $("#openOfWhat").val()

		console.log "you said: " + youSaid
		if (@whatShouldIOpenWith().nextState == youSaid)
			$('#q3').show("slow")
			answerBox.text(@messages.yay)

			juliaResponds = @whatShouldJuliaRespondWith().text
			$('#juliaSays').text(juliaResponds)

			if (juliaResponds == "pass")
				$('#q5').show("slow")
		else
			answerBox.text(@messages.nay)	

	whatShouldIOpenWith: () ->
		myBid = @evaluateOpenBid(@myHand)
		@myBids[0] = myBid
		myBid

	evaluateOpenBid: (hand) ->
		handIsBalanced = @isHandBalanced(hand)
		handIsWorth = @scoreIt(hand)

		# based on what the score is, decide which of these states you fit
		open_bid_pass = {low: 0, high: 12, nextState: "bid_pass"}
		open_bid_1NT = {low: 15, high: 17, balanced: true, nextState: "bid_1NT"}
		open_bid_2NT = {low: 20, high: 22, balanced: true, nextState: "bid_2NT"}
		open_bid_3NT = {low: 25, high: 27, balanced: true, nextState: "bid_3NT"}
		open_bid_1H = {low: 13, high: 21, suit: "hearts", cards: 4, 	 nextState: "bid_1H"}
		open_bid_1S = {low: 13, high: 21, suit: "spades", cards: 5, 	 nextState: "bid_1S"}
		open_bid_1D = {low: 13, high: 21, suit: "diamonds",  cards: 4, 	 nextState: "bid_1D"}
		open_bid_1C = {low: 13, high: 21, suit: "clubs", 	cards: 3, 	 nextState: "bid_1C"}

		# need to sort these by importance
		openBid = [open_bid_2NT, open_bid_3NT, open_bid_1NT ,
				open_bid_1S, open_bid_1H, open_bid_1D, open_bid_1C, open_bid_pass]
		possibleStates = []

		#debugger
		for bid in openBid
			if bid.low <= handIsWorth and bid.high >= handIsWorth
				# check if we match the balanced condition
				# otherwise check if we match the suit condition
				# otherwise just add it
				if bid.balanced is true
					possibleStates.push bid unless !@isHandBalanced(hand)
				else if bid.suit
					switch bid.suit
						when "hearts" then possibleStates.push bid unless hand.hearts.length < 5
						when "spades" then possibleStates.push bid unless hand.spades.length < 5
						when "diamonds" then possibleStates.push bid unless hand.diamonds.length < 4
						when "clubs" then possibleStates.push bid unless hand.diamonds.length < 3
				else 
					possibleStates.push bid 

		console.log("applicable bids: ")
		console.log possibleStates	

		return possibleStates[0]
		
	
	whatShouldJuliaRespondWith: () ->
		herHand = @hands.south
		herHandIsWorth = @scoreIt(herHand)
		handIsBalanced = @isHandBalanced(herHand)
		
		
		myBid = @myBids[0].text
		#if i passed, let her do an open bid
		if myBid == "pass"
			return @evaluateOpenBid(herHand)
		else if herHandIsWorth < 6
			return @myBids.pass
		else if myBid == "1C"
			# can i try for a minor/ major suit?
			if (herHand.diamonds.length > herHand.hearts.length and
			herHand.diamonds.length > herHand.spades.length and
			herHand.diamonds.length >= 4)
				return @bids.D1
			else if herHand.hearts.length >= 4
				return @bids.D2
			else if herHand.spades.length >= 4
				return @bids.S2
			# you can single raise a minor if you have 4+ match and 6-10 points and no major suit
			else if herHand.clubs.length >= 3 
				if herHandIsWorth <= 10 then return @bids.C2 else return @bids.C3
			else
				return @bids.baffled
		else if myBid == "1D"
			# can i try for a major suit?
			if herHand.hearts.length >= 4
				return @bids.D2
			else if herHand.spades.length >= 4
				return @bids.S2
			# you can single raise a minor if you have 4+ match and 6-10 points and no major suit
			else if herHand.diamonds.length >= 3 
				if herHandIsWorth <= 10 then return @bids.D2 else return @bids.D3
			else
				return @bids.baffled
		else if myBid == "1H"
			# she can single raise a major with 3 matching cards and 6-10 pts to show fit
			if herHand.hearts.length >= 3
				if herHandIsWorth <= 10 then return @bids.S2 else return @bids.S3
			else
				return @bids.baffled
		else if myBid == "1S"
			# she can single raise a major with 3 matching cards and 6-10 pts to show fit
			if herHand.hearts.length >= 3
				if herHandIsWorth <= 10 then return @bids.S2 else return @bids.S3
			# she can jump to a new minor/major with a 4+ 5+ suit
			else
				return @bids.baffled
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



