class Hooman
	constructor: ->
		@hand = {}
		@handIsBalanced =
		@handIsWorth = 0
		@bids = [null, null]

	setupHand: (deck, hand) ->
		@hand = hand
		@handIsBalanced = deck.isHandBalanced(hand);
		@handIsWorth = deck.scoreIt(hand)

	getOpenBid: ->
		myBid = @evaluateOpenBid()
		@bids[0] = myBid
		myBid.nextState

	evaluateOpenBid: ->
		# based on what the score is, decide which of these states you fit
		open_bid_pass = {low: 0, high: 12, nextState: "bid_pass"}
		open_bid_1NT = {low: 15, high: 17, balanced: true, nextState: "bid_1NT"}
		open_bid_2NT = {low: 20, high: 22, balanced: true, nextState: "bid_2NT"}
		open_bid_3NT = {low: 25, high: 27, balanced: true, nextState: "bid_3NT"}
		open_bid_1H = {low: 13, high: 21, suit: "hearts", cards: 4, 	 nextState: "bid_1H"}
		open_bid_1S = {low: 13, high: 21, suit: "spades", cards: 5, 	 nextState: "bid_1S"}
		open_bid_1D = {low: 13, high: 21, suit: "diamonds",  cards: 4, 	 nextState: "bid_1D"}
		open_bid_1C = {low: 13, high: 21, suit: "clubs", 	cards: 3, 	 nextState: "bid_1C"}
		open_bid_2C = {low: 22, high: 40, nextState: "bid_2C"}

		# need to sort these by importance
		openBid = [open_bid_2NT, open_bid_3NT, open_bid_1NT,
				open_bid_1S, open_bid_1H, open_bid_1D, open_bid_1C, open_bid_pass]
		possibleStates = []

		for bid in openBid
			if bid.low <= @handIsWorth and bid.high >= @handIsWorth
				# check if we match the balanced condition
				# otherwise check if we match the suit condition
				# otherwise just add it
				if bid.balanced is true
					possibleStates.push bid unless !@handIsBalanced
				else if bid.suit
					switch bid.suit
						when "hearts" then possibleStates.push bid unless @hand.hearts.length < 5
						when "spades" then possibleStates.push bid unless @hand.spades.length < 5
						when "diamonds" then possibleStates.push bid unless @hand.diamonds.length < 4
						when "clubs" then possibleStates.push bid unless @hand.diamonds.length < 3
				else 
					possibleStates.push bid 

		#console.log("applicable bids: ")
		#console.log possibleStates	

		return possibleStates[0]	


window.Hooman = Hooman