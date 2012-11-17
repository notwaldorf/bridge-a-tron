class Thingamadoer
	constructor: ->
		@deck = new Deck()
		@messages = new Messages()

		@hooman = new Hooman()
		@julia = new Julia()

		@setUpClicks()
		@newGame()

	setUpClicks: ->
		$("#deal").click =>
			@newGame()
			@showCards()
		
		# counting points
		$("#pointsScore").click => @scoreYourBid()
		$('#pointsHalpBtn').click => $('#pointsHalpText').toggle("slow")
	
		# you bid
		$('#yourBidHalpBtn').click => $('#yourBidHalpText').toggle("slow")
		$("#yourBidActionPass").click => @checkYourBid(true)
		$("#yourBidActionBid").click =>	@checkYourBid(false)			

	newGame: ->
		$('#step1').addClass('active')
		$('#step2').removeClass('active')
		$('#step3').removeClass('active')
		$('#points').show("fast")
		$('#pointsHalpText').hide("fast")
		$('#pointsAnswer').hide("fast")
		$('#yourBid').hide("fast")
		$('#yourBidHalpText').hide("fast")
		$('#yourBidAnswer').hide("fast")
		$('#juliaBids').hide("fast")

		@hands = @deck.gimmeHands()
		@hooman.setupHand(@deck, @hands.north)
		@julia.setupHand(@deck, @hands.south)

		$('#pointsHint').text(@hooman.handIsWorth)
		$('#yourBidHint').text(@hooman.getOpenBid())

	showCards: ->
		for suit in @deck.suitNames
			prettifiedHand = ""
			for card in @hooman.hand[suit]
				prettifiedHand += @deck.valueNames[card] + " "
			$("##{suit}").text(prettifiedHand)    

	### STEP 1 ###
	scoreYourBid: () ->
		answerBox = $('#pointsAnswer') 
		
		if (parseInt($('#pointsInput').val()) != @hooman.handIsWorth)
			answerBox.text(@messages.nay)
		else
			answerBox.text(@messages.yay)
			$('#yourBid').show("slow")

	checkYourBid: (iPassed) ->
		answerBox = $('#yourBidAnswer') 
		$('#openBidWhy').show()
		if iPassed
			youSaid = "bid_pass"
		else
			youSaid = "bid_" + $('#yourBidInputValue').val() + $("#yourBidInputSuit").val()

		if (@hooman.getOpenBid() == youSaid)
			$('#step1').removeClass('active')
			$('#step2').addClass('active')
			$('#points').hide("slow")
			$('#pointsHalpText').hide("slow")
			$('#yourBid').hide("slow")
			$('#yourBidHalpText').hide("slow")
			$('#juliaBids').show("slow")
		else
			answerBox.show();
			answerBox.text(@messages.nay)		

	
class Messages
	constructor: ->
		@yay = "Bingo, bango!"
		@nay = "That's not right. Try again!"

window.Thingamadoer = Thingamadoer



