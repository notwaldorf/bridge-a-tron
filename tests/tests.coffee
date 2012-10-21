module "card dealing stuff"

deck = new Deck()
shuffledDeck = deck.shuffle()
hands = deck.gimmeHands()

sortMagic = ((a,b) => parseInt(a) - parseInt(b))

test "deck is very likely created ok", ->
	# check some cards at random
	equal deck.unshuffled[0].suit	, 0
	equal deck.unshuffled[0].value  , 0
	equal deck.unshuffled[14].suit  , 1
	equal deck.unshuffled[14].value , 1
	equal deck.unshuffled[28].suit  , 2
	equal deck.unshuffled[28].value , 2
	equal deck.unshuffled[50].suit  , 3
	equal deck.unshuffled[50].value , 11

test "my sort function actually works", ->
	
	deepEqual [1,2,3], [3,2,1].sort(sortMagic)
	deepEqual [1,2,3,4,5,6], [1,2,3,4,5,6].sort(sortMagic)
	deepEqual [], [].sort(sortMagic)
	deepEqual [1], [1].sort(sortMagic)
	deepEqual [1,11,12], [1,12,11].sort(sortMagic)

test "shuffling doesn't lose cards", ->
	equal shuffledDeck.length, deck.unshuffled.length
	deepEqual [0..51], shuffledDeck.sort(sortMagic)

test "everyone has enough cards", ->
	for side in deck.sides
		total = 0
		for suit in deck.suitNames
			total += hands[side][suit].length
		equal 13, total

test "everyone's cards makes the whole deck", ->
	allTheCards = {clubs:[], diamonds:[], hearts:[], spades: []}

	for suit in deck.suitNames
		allTheCards[suit] = hands.north[suit].concat(hands.south[suit]).concat(hands.east[suit]).concat(hands.west[suit])

	for suit in deck.suitNames
		equal 13, allTheCards[suit].length
		deepEqual [0..12], allTheCards[suit].sort(sortMagic)
