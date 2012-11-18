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

	getResponse: (previousBid) ->
		console.log("previous bid ", previousBid)
		if previousBid == "bid_pass" then myBid = @evaluateOpenBid() else myBid = @evaluateResponse(previousBid)
		@bids[0] = myBid
		myBid.nextState

	evaluateOpenBid: ->
		# based on what the score is, decide which of these states you fit
		open_bid_pass = {low: 0, high: 40, nextState: "bid_pass"}
		open_bid_1NT = {low: 15, high: 17, balanced: true, nextState: "bid_1NT"}
		open_bid_2NT = {low: 20, high: 22, balanced: true, nextState: "bid_2NT"}
		open_bid_3NT = {low: 25, high: 27, balanced: true, nextState: "bid_3NT"}
		open_bid_1H = {low: 13, high: 21, suit: "hearts", cards: 5, 	 nextState: "bid_1H"}
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
						when "hearts" then possibleStates.push bid unless @hand.hearts.length < bid.cards
						when "spades" then possibleStates.push bid unless @hand.spades.length < bid.cards
						when "diamonds" then possibleStates.push bid unless @hand.diamonds.length < bid.cards
						when "clubs" then possibleStates.push bid unless @hand.clubs.length < bid.cards
				else 
					possibleStates.push bid 

		console.log("applicable bids: ", possibleStates)	

		return possibleStates[0]	

	evaluateResponse: (previousBid) ->
		# based on what the score is, decide which of these states you fit
		bid_pass = {low: 0, high: 40, nextState: "bid_pass", prevState:["bid_2NT", "bid_3NT", "bid_1NT",
		"bid_1S", "bid_1H", "bid_1D", "bid_1C", "bid_pass"]}
		
		# 1 of a new suit
		bid_1D = {low: 6, high: 20, suit: "diamonds", cards: 4, prevState:["bid_1C"], nextState: "bid_1D"}
		bid_1H = {low: 6, high: 20, suit: "hearts", cards: 4, prevState:["bid_1C", "bid_1D"], nextState: "bid_1H"}
		bid_1S = {low: 6, high: 20, suit: "spades", cards: 4, prevState:["bid_1C", "bid_1D", "bid_1H"], nextState: "bid_1S"}
		
		# 2 of a new minor
		bid_2C_n = {low: 10, high: 11, suit: "clubs", cards: 4, prevState:["bid_1C", "bid_1D", "bid_1H", "bid_1S", "bid_1NT"], nextState: "bid_2C"}
		bid_2D_n = {low: 10, high: 11, suit: "diamonds", cards: 4, prevState:["bid_1D", "bid_1H", "bid_1S", "bid_1NT", "bid_2C"], nextState: "bid_2D"}
		
		# 2 of a new major
		bid_2H_n = {low: 10, high: 11, suit: "hearts", cards: 5, prevState:["bid_1C", "bid_1D", "bid_1H", "bid_1S", "bid_1NT", "bid_2C", "bid_2D"], nextState: "bid_2H"}
		bid_2S_n = {low: 10, high: 11, suit: "spades", cards: 5, prevState:["bid_1C", "bid_1D", "bid_1H", "bid_1S", "bid_1NT", "bid_2C", "bid_2D", "bid_2S",], nextState: "bid_2S"}
		
		# single raise of major
		bid_2S_r = {low: 6, high: 9, suit: "spades", cards: 3, prevState:["bid_1S"], nextState: "bid_2S"}
		bid_3S_r = {low: 10, high: 11, suit: "spades", cards: 3, prevState:["bid_1S"], nextState: "bid_3S"}
		bid_2H_r = {low: 6, high: 9, suit: "hearts", cards: 3, prevState:["bid_1H"], nextState: "bid_2H"}
		bid_3H_r = {low: 10, high: 11, suit: "hearts", cards: 3, prevState:["bid_1H"], nextState: "bid_3H"}
		
		# single raise of minor
		bid_2C_r = {low: 6, high: 9, suit: "clubs", cards: 4, prevState:["bid_1C"], nextState: "bid_2C"}
		bid_3C_r = {low: 10, high: 11, suit: "clubs", cards: 4, prevState:["bid_1C"], nextState: "bid_3C"}
		bid_2D_r = {low: 6, high: 9, suit: "diamonds", cards: 4, prevState:["bid_1D"], nextState: "bid_2D"}
		bid_3D_r = {low: 10, high: 11, suit: "diamonds", cards: 4, prevState:["bid_1D"], nextState: "bid_3D"}

		# no trump
		bid_1NT = {low: 6, high: 9, balanced: true, prevState:["bid_1D", "bid_1H", "bid_1S"], nextState: "bid_1NT"}
		bid_2NT = {low: 9, high: 12, balanced: true, prevState:["bid_1NT"], nextState: "bid_2NT"}

		# need to sort these by importance
		# confirm major fit, raise single, confirm minor fit
		bids = [bid_2S_r, bid_3S_r, bid_2H_r, bid_3H_r, 
		bid_1H, bid_1S, bid_1D, bid_1NT, 
		bid_2C_r, bid_2C_r, bid_2D_r, bid_3D_r,
		bid_2C_n, bid_2D_n, bid_2H_n, bid_2S_n, 
		bid_2NT, bid_pass] 
		possibleStates = []

		for bid in bids
			if bid.low <= @handIsWorth and bid.high >= @handIsWorth
				# check if the previous bid is a prereq for this state
				wereOk = false
				for prev in bid.prevState
					if prev == previousBid then wereOk = true

				if wereOk
					console.log(bid.nextState + " matches prereq of " + previousBid)
				else 
					console.log(bid.nextState + " doesnt match prereq of " + previousBid)
				continue unless wereOk

				# check if we match the balanced condition
				# otherwise check if we match the suit condition
				# otherwise just add it
				if bid.balanced is true
					possibleStates.push bid unless !@handIsBalanced
				else if bid.suit
					switch bid.suit
						when "hearts" then possibleStates.push bid unless @hand.hearts.length < bid.cards
						when "spades" then possibleStates.push bid unless @hand.spades.length < bid.cards
						when "diamonds" then possibleStates.push bid unless @hand.diamonds.length < bid.cards
						when "clubs" then possibleStates.push bid unless @hand.clubs.length < bid.cards
				else 
					possibleStates.push bid 

		console.log("applicable bids: ", possibleStates)	

		return possibleStates[0]

window.Hooman = Hooman