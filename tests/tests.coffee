module "card dealing stuff"

julia = new Thingamadoer()
# because typing is the worst
hands = julia.hands
deck = julia.deck

sortMagic = ((a,b) => parseInt(a) - parseInt(b))

test "deck is very likely created ok", ->
	sampleDeck = new Deck()
	# check some cards at random
	equal sampleDeck.unshuffled[0].suit	  , 0
	equal sampleDeck.unshuffled[0].value  , 0
	equal sampleDeck.unshuffled[14].suit  , 1
	equal sampleDeck.unshuffled[14].value , 1
	equal sampleDeck.unshuffled[28].suit  , 2
	equal sampleDeck.unshuffled[28].value , 2
	equal sampleDeck.unshuffled[50].suit  , 3
	equal sampleDeck.unshuffled[50].value , 11

test "my sort function actually works", ->
	deepEqual [1,2,3], [3,2,1].sort(sortMagic)
	deepEqual [1,2,3,4,5,6], [1,2,3,4,5,6].sort(sortMagic)
	deepEqual [], [].sort(sortMagic)
	deepEqual [1], [1].sort(sortMagic)
	deepEqual [1,11,12], [1,12,11].sort(sortMagic)

test "shuffling doesn't lose cards", ->
	sampleDeck = new Deck()
	shuffledDeck = sampleDeck.shuffle()
	equal shuffledDeck.length, sampleDeck.unshuffled.length
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

test "we can score hands", ->
	# even though they are illegal hands
	hand1 = {clubs:[], diamonds:[], hearts:[], spades: [0]}
	hand2 = {clubs:[], diamonds:[], hearts:[], spades: [10]}
	hand3 = {clubs:[], diamonds:[], hearts:[], spades: [11]}
	hand4 = {clubs:[], diamonds:[], hearts:[], spades: [12]}
	hand5 = {clubs:[1], diamonds:[2], hearts:[3], spades: [4]}
	hand6 = {clubs:[0], diamonds:[0], hearts:[0], spades: [0]}
	hand7 = {clubs:[10], diamonds:[11], hearts:[12], spades: [0]}
	hand8 = {clubs:[10,11,12], diamonds:[11,1,2], hearts:[12,3,4], spades: [0,11]}

	equal julia.scoreIt(hand1), 4
	equal julia.scoreIt(hand2), 1
	equal julia.scoreIt(hand3), 2
	equal julia.scoreIt(hand4), 3
	equal julia.scoreIt(hand5), 0
	equal julia.scoreIt(hand6), 16
	equal julia.scoreIt(hand7), 10
	equal julia.scoreIt(hand8), 17

test "there's only 40 points in the deck", ->
	allThePoints = 0;
	for side in julia.deck.sides
		allThePoints += julia.scoreIt(hands[side])

	equal allThePoints, 40

test "balanced hands", ->
	handB1 = {clubs:[1,2,3,4], diamonds:[1,2,3], hearts:[1,2,3], spades: [1,2,3]}
	handB2 = {clubs:[1,2,3,4], diamonds:[1,2,3,4], hearts:[1,2,3], spades: [1,2]}
	handB3 = {clubs:[1,2,3], diamonds:[1,2,3,4], hearts:[1,2], spades: [1,2,3,4]}
	handNB1 = {clubs:[1], diamonds:[1], hearts:[1], spades: [1,2,3,4,5,6,7,8,9,10]}
	handNB2 = {clubs:[1,2], diamonds:[1,2,3], hearts:[1,2,3], spades: [1,2,3,4,5]}
	handNB3 = {clubs:[1,2,3], diamonds:[1,2], hearts:[1,2,3,4,5,6], spades: [1,2]}

	equal julia.isHandBalanced(handB1), true
	equal julia.isHandBalanced(handB2), true
	equal julia.isHandBalanced(handB3), true
	equal julia.isHandBalanced(handNB1), false
	equal julia.isHandBalanced(handNB2), false
	equal julia.isHandBalanced(handNB3), false



