extends Node

class_name BotAI

# Probability tables for Naive Bayes
var color_probabilities: Dictionary = {}
var type_probabilities: Dictionary = {}
var value_probabilities: Dictionary = {}

# Game state tracking
var cards_played: Array = []
var opponent_cards_count: Dictionary = {}
var known_opponent_cards: Dictionary = {}

func _init():
	_initialize_probabilities()

func _initialize_probabilities():
	# Initialize probability tables for colors
	for color in Card.CardColor.keys():
		color_probabilities[color] = 0.2  # Equal initial probability
	
	# Initialize probability tables for card types
	for type in Card.CardType.keys():
		if type == "NUMBER":
			type_probabilities[type] = 0.6  # Numbers are more common
		else:
			type_probabilities[type] = 0.08  # Special cards are less common
	
	# Initialize probability tables for values (0-9)
	for i in range(10):
		value_probabilities[i] = 0.1  # Equal probability for each number

func update_probabilities(played_card: Card):
	cards_played.append(played_card)
	
	# Update probabilities based on played card
	var total_cards = cards_played.size()
	
	# Update color probabilities
	for color in Card.CardColor.keys():
		var color_count = cards_played.count(func(card): return card.color == Card.CardColor[color])
		color_probabilities[color] = float(color_count) / total_cards
	
	# Update type probabilities
	for type in Card.CardType.keys():
		var type_count = cards_played.count(func(card): return card.card_type == Card.CardType[type])
		type_probabilities[type] = float(type_count) / total_cards
	
	# Update value probabilities for number cards
	var number_cards = cards_played.filter(func(card): return card.card_type == Card.CardType.NUMBER)
	var total_numbers = number_cards.size()
	if total_numbers > 0:
		for i in range(10):
			var value_count = number_cards.count(func(card): return card.value == i)
			value_probabilities[i] = float(value_count) / total_numbers

func choose_best_card(hand: Array, top_card: Card) -> Card:
	var playable_cards = hand.filter(func(card): return card.can_play_on(top_card))
	if playable_cards.is_empty():
		return null
		
	var best_card = null
	var highest_score = -1.0
	
	for card in playable_cards:
		var score = _calculate_card_score(card)
		if score > highest_score:
			highest_score = score
			best_card = card
	
	return best_card

func _calculate_card_score(card: Card) -> float:
	var score = 1.0
	
	# Color score
	score *= color_probabilities[Card.CardColor.keys()[card.color]]
	
	# Type score
	score *= type_probabilities[Card.CardType.keys()[card.card_type]]
	
	# Value score for number cards
	if card.card_type == Card.CardType.NUMBER:
		score *= value_probabilities[card.value]
	
	# Bonus for special cards when opponents have few cards
	if card.card_type in [Card.CardType.SKIP, Card.CardType.REVERSE, Card.CardType.DRAW_TWO]:
		var opponents_with_few_cards = opponent_cards_count.values().count(func(count): return count <= 2)
		score *= (1.0 + (opponents_with_few_cards * 0.2))
	
	# Bonus for Wild Draw Four when we have matching colors
	if card.card_type == Card.CardType.WILD_DRAW_FOUR:
		score *= 1.5
	
	return score

func update_opponent_cards(player_id: int, card_count: int):
	opponent_cards_count[player_id] = card_count

func record_opponent_card(player_id: int, card: Card):
	if not known_opponent_cards.has(player_id):
		known_opponent_cards[player_id] = []
	known_opponent_cards[player_id].append(card) 