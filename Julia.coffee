class Julia
	constructor: ->
		@hand = {}
		@handIsBalanced =
		@handIsWorth = 0
		@bids = [null, null]

	setupHand: (deck, hand) ->
		@hand = hand
		@handIsBalanced = deck.isHandBalanced(hand);
		@handIsWorth = deck.scoreIt(hand)
		
window.Julia = Julia
