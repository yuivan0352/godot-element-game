# Primordial King (Made in Godot)

* [ -- Idea for the game -- ] The Primordial King (Name still debatable)

## Story (We can describe a story here)

* Work in Progress..

## Design (The style of the game)

* Inspired from Baldurs Gate 3 we created...

### Node Structure Reference

```bash
World
├── UI
│   └── UserInterface
├── Environment
│   ├── Map
│   │   ├── Ground    (TileLayer)
│   │   ├── Objects   (TileLayer)
│   │   └── Overlay   (TileLayer)
│   └── OverviewCamera
├── Entities
│   ├── Players
│   │   ├── Character1
│   │   ├── Character2
│   │   └── Character3
│   └── Enemies
└── Systems
	├── TurnQueue
	└── CombatSystem
```

### Structure Explanation

* A general look at what our structure should look like for reference, descriptions of the details for the nodes below
  
  #### Environment

  * Houses all level-related nodes and environmental elements.
	* Environment handles all our different levels with separate tile layers

  * **Map**: Container for our expanding map
	* Our map is a TileLayer node and will use patterns to extend the initial map to create a bigger map for our different levels
  * **OverviewCamera**: Main camera node for scene visualization and follows characters as the turns progress (No camera for Enemies right now)

  #### Entities

  Groups all game entities and interactive elements.

  * **Players**: Contains player-controlled characters
  * **Enemies**: Contains enemy units and NPCs

  #### Systems

  Contains game logic and management nodes.

  * **TurnQueue**: Handles turn-based gameplay logic
  * **CombatSystem**: Manages combat interactions

## Credits  

* Jerry Weng
* Ivan Yu
* Darren Liu
* Chandler Nauta
