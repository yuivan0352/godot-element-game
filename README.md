# Primordial King (Made in Godot)

* [ -- Idea for the game -- ]

## Story (We can describe a story here)

## Design (The style of the game)

* Inspired from Baldurs Gate 3 we created...

### Node Structure Reference
```
World
├── UI
│   └── UserInterface
├── Environment
│   ├── Maps
│   │   ├── Level1
│   │   │   ├── Ground    (TileLayer)
│   │   │   ├── Objects   (TileLayer)
│   │   │   └── Overlay   (TileLayer)
│   │   └── Level2
│   │       └── ...
│   └── OverviewCamera
├── Entities
│   ├── Players
│   │   ├── Character1
│   │   ├── Character2
│   │   └── Character3
│   └── Enemies
└── Systems
    ├── TurnManager
    └── CombatSystem
```
### Structure Explanation

  * A general look at what our structure should look like for reference, descriptions of the details for the nodes below
  
  #### Environment
  * Houses all level-related nodes and environmental elements.
      * Environment handles all our different levels with separate tile maps
      * Ideally should be separate scenes for each level
  - **Maps**: Container for all game levels
    - Each level contains multiple TileMap nodes for different layers (ground, objects, overlay)
  - **OverviewCamera**: Main camera node for scene visualization
  
  #### Entities
  Groups all game actors and interactive elements.
  - **Players**: Contains player-controlled characters
  - **Enemies**: Contains enemy units and NPCs
  
  #### Systems
  Contains game logic and management nodes.
  - **TurnManager**: Handles turn-based gameplay logic
  - **CombatSystem**: Manages combat interactions

## Credits  
  * Jerry Weng
  * Ivan Yu
  * Darren Liu
  * Chandler Nauta
