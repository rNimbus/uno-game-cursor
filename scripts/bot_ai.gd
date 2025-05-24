extends Node

class_name BotAI

# Probability tables for Naive Bayes
var color_probabilities: Dictionary = {}
var type_probabilities: Dictionary = {}
var value_probabilities: Dictionary = {}

# Additional probability tables from new implementation
var color_likelihood: Dictionary = {}  # P(Player plays card | Color)
var value_likelihood: Dictionary = {}  # P(Player plays card | Value)

# Game state tracking
var cards_played: Array = []
var discard_memory: Array = []  # Memory of all discarded cards
var opponent_cards_count: Dictionary = {}
var known_opponent_cards: Dictionary = {}
var player_history: Array = []  # Track player's moves for better learning

# Scoring weights for move evaluation
var weight_color_match: float = 2.0
var weight_number_match: float = 1.5
var weight_special_card: float = 3.0
var weight_wild_card: float = 4.0
var weight_card_advantage: float = 1.0
const MAX_DEPTH = 3  # Maximum depth for DFS analysis

func _init():
	_initialize_probabilities()

func _initialize_probabilities():
	# Initialize probability tables for colors
	for color in Card.CardColor.keys():
		color_probabilities[color] = 0.2  # Equal initial probability
		color_likelihood[color] = 0.25  # Equal initial likelihood
	
	# Initialize probability tables for card types
	for type in Card.CardType.keys():
		if type == "NUMBER":
			type_probabilities[type] = 0.6  # Numbers are more common
		else:
			type_probabilities[type] = 0.08  # Special cards are less common
	
	# Initialize probability tables for values (0-9)
	for i in range(10):
		value_probabilities[i] = 0.1  # Equal probability for each number
		value_likelihood[str(i)] = 0.1  # Equal initial likelihood

	# Initialize likelihood for special values
	for type in ["SKIP", "REVERSE", "DRAW_TWO", "WILD", "WILD_DRAW_FOUR"]:
		value_likelihood[type] = 0.1

func update_probabilities(played_card: Card):
	cards_played.append(played_card)
	player_history.append(played_card)
	discard_memory.append(played_card)
	
	# Update opponent card counts and adjust weights
	for player_id in opponent_cards_count.keys():
		if opponent_cards_count[player_id] <= 2:
			# Opponent is close to winning, prioritize defensive plays
			weight_special_card = 4.5  # Increase weight temporarily

func choose_best_card(hand: Array, top_card: Card) -> Card:
	var playable_cards = hand.filter(func(card): return card.can_play_on(top_card))
	if playable_cards.is_empty():
		return null
	
	var best_card = null
	var best_score = -1.0
	
	# Use DFS to analyze each possible move
	for card in playable_cards:
		var score = evaluate_move_dfs(card, hand.duplicate(), 0)
		if score > best_score:
			best_score = score
			best_card = card
	
	return best_card

func evaluate_move_dfs(card: Card, remaining_hand: Array, depth: int) -> float:
	if depth >= MAX_DEPTH:
		return calculate_base_score(card)
	
	var score = calculate_base_score(card)
	remaining_hand.erase(card)
	
	# Analyze potential future moves
	var potential_moves = get_potential_moves(remaining_hand)
	if not potential_moves.is_empty():
		var best_future_score = 0.0
		for move in potential_moves:
			var future_score = evaluate_move_dfs(move, remaining_hand.duplicate(), depth + 1)
			best_future_score = max(best_future_score, future_score)
		score += best_future_score * (1.0 / (depth + 1))  # Weight future moves less with depth
	
	return score

func get_potential_moves(hand: Array) -> Array:
	var moves = []
	for card in hand:
		# Check if this move would be advantageous
		if is_advantageous_move(card):
			moves.append(card)
	return moves

func is_advantageous_move(card: Card) -> bool:
	# Check if this card type has been successful in the past
	var similar_plays = discard_memory.filter(func(played): 
		return played.card_type == card.card_type or played.color == card.color
	)
	
	# Check if opponents are close to winning
	var opponents_near_win = false
	for count in opponent_cards_count.values():
		if count <= 2:
			opponents_near_win = true
			break
	
	# Special cards are advantageous when opponents are close to winning
	if opponents_near_win and card.card_type != Card.CardType.NUMBER:
		return true
	
	# Cards that match frequently played colors/types are advantageous
	return similar_plays.size() >= 2

func calculate_base_score(card: Card) -> float:
	var score = 0.0
	
	# Analyze color frequency in discard pile
	var color_frequency = get_color_frequency()
	if card.color != Card.CardColor.WILD:
		score += weight_color_match * (color_frequency.get(card.color, 0) / max(1, discard_memory.size()))
	
	# Score based on card type
	match card.card_type:
		Card.CardType.WILD_DRAW_FOUR:
			score += weight_wild_card * 1.5
		Card.CardType.WILD:
			score += weight_wild_card
		Card.CardType.DRAW_TWO, Card.CardType.SKIP, Card.CardType.REVERSE:
			score += weight_special_card
		Card.CardType.NUMBER:
			# Check if number matches last played number
			if not discard_memory.is_empty():
				var last_card = discard_memory.back()
				if last_card.card_type == Card.CardType.NUMBER and last_card.value == card.value:
					score += weight_number_match
	
	# Consider card advantage
	score += weight_card_advantage * (1.0 / max(1, get_min_opponent_cards()))
	
	return score

func get_color_frequency() -> Dictionary:
	var frequency = {}
	for card in discard_memory:
		if card.color != Card.CardColor.WILD:
			frequency[card.color] = frequency.get(card.color, 0) + 1
	return frequency

func get_min_opponent_cards() -> int:
	if opponent_cards_count.is_empty():
		return 1
	return opponent_cards_count.values().min()

func update_opponent_cards(player_id: int, card_count: int):
	opponent_cards_count[player_id] = card_count

func record_opponent_card(player_id: int, card: Card):
	if not known_opponent_cards.has(player_id):
		known_opponent_cards[player_id] = []
	known_opponent_cards[player_id].append(card)

func choose_best_color(hand: Array) -> int:
	var color_scores = {}
	
	# Initialize scores for each color
	for color in range(4):  # Excluding WILD
		color_scores[color] = 0.0
	
	# Score based on cards in hand
	for card in hand:
		if card.color != Card.CardColor.WILD:
			color_scores[card.color] += 1.0
	
	# Score based on discard memory
	var color_frequency = get_color_frequency()
	for color in color_frequency:
		color_scores[color] += 0.5 * (color_frequency[color] / max(1, discard_memory.size()))
	
	# Choose color with highest score
	var best_color = Card.CardColor.RED
	var best_score = 0.0
	
	for color in color_scores:
		if color_scores[color] > best_score:
			best_score = color_scores[color]
			best_color = color
	
	return best_color 
