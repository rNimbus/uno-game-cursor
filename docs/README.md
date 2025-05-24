# UNO Game Documentation

## Game Overview
The UNO game is implemented as a fully functional card game with AI opponents using the Godot game engine. The game follows standard UNO rules and features a complete game loop with multiple AI opponents.

## Core Components

### 1. Game Manager (`game_manager.gd`)
- **Game Constants**
  - Initial cards per player: 7
  - Bot thinking time: 1.0 seconds

- **State Management**
  - Tracks players, current player index, and game direction
  - Manages deck and discard pile
  - Handles game state changes and turn progression
  - Tracks finished players and active players

- **Game Flow**
  - Initializes game setup with 1 human player and 3 AI bots
  - Manages card dealing and shuffling
  - Handles turn progression and special card effects
  - Implements win conditions and game ending

### 2. UI Manager (`ui_manager.gd`)
- **Visual Components**
  - Player hand display
  - Bot hands visualization
  - Discard and draw piles
  - Color selector for wild cards
  - Turn and direction indicators
  - Current color display

- **Interface Features**
  - Card interaction handling
  - Visual feedback for game state
  - Dynamic UI updates
  - Direction arrows and player labels

### 3. Bot AI (`bot_ai.gd`)
- **AI Implementation**
  - Uses Naive Bayes algorithm for decision making
  - Maintains probability tables for:
    - Color probabilities
    - Type probabilities
    - Value probabilities
    - Color likelihood
    - Value likelihood

- **Decision Making**
  - Tracks played cards and opponent behavior
  - Updates probabilities based on game progress
  - Calculates optimal card choices
  - Special handling for strategic cards

### 4. Game Over System (`game_over.gd`)
- **End Game Features**
  - Displays final rankings with medals (🥇, 🥈, 🥉)
  - Shows remaining cards for non-winning players
  - Options to play again or return to main menu

## Game Features

### Card Types
1. **Number Cards (0-9)**
   - Available in four colors (Red, Blue, Green, Yellow)

2. **Special Cards**
   - Skip
   - Reverse
   - Draw Two
   - Wild
   - Wild Draw Four

### Game Mechanics
1. **Turn System**
   - Clockwise/Counter-clockwise rotation
   - Skip and reverse card effects
   - Draw penalties handling

2. **Card Playing Rules**
   - Color matching
   - Number matching
   - Special card effects
   - Wild card color selection

3. **Winning Conditions**
   - First player to empty their hand wins
   - Rankings based on remaining cards

## AI Strategy
The AI bots use a sophisticated decision-making system:

1. **Probability Tracking**
   - Monitors card frequency
   - Analyzes player patterns
   - Updates probabilities in real-time

2. **Card Selection**
   - Evaluates optimal plays based on:
     - Current game state
     - Card probabilities
     - Special card opportunities
     - Opponent card counts

3. **Strategic Considerations**
   - Prioritizes Wild Draw Four cards
   - Considers opponent hand sizes
   - Adapts to game direction
   - Learns from player history

## User Interface
1. **Main Game Screen**
   - Central play area with discard and draw piles
   - Player hand at bottom
   - Bot hands on sides and top
   - Game information panel
   - Direction indicator

2. **Interactive Elements**
   - Clickable cards
   - Draw pile interaction
   - Color selector for wild cards
   - Turn indicators
   - Player labels

## Current Implementation Status
The game is fully implemented with all core UNO features:
- ✅ Complete game loop
- ✅ AI opponent system
- ✅ Card mechanics
- ✅ User interface
- ✅ Win conditions
- ✅ Game over screen
- ✅ Play again functionality

The game provides a complete UNO experience with intelligent AI opponents and a polished user interface, making it ready for gameplay. 