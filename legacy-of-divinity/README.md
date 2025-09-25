# Legacy of Divinity
*An MMORPG of Biblical Proportions*

## Overview

Legacy of Divinity is an ambitious MMORPG that intertwines biblical narratives, moral complexities, and human history with innovative gameplay mechanics. Players navigate the dual paths of good and evil, crafting destinies that echo through generations in a world that mirrors ancient biblical landscapes.

## 🎮 Key Features

### **Generational Legacy System**
- Your character's choices affect descendants across multiple generations
- Family reputation and divine favor carry forward
- Ancestral skills and knowledge passed down through bloodlines
- Dynamic family tree with blessings and curses

### **Moral Choice Framework**
- Deep moral dilemma system with real consequences
- Alignment system ranging from Righteous to Wicked
- Choices impact both immediate gameplay and long-term legacy
- No simple good/evil - nuanced moral complexity

### **Biblical-Inspired Classes**
- **Prophet**: Divine wisdom and faith-based abilities
- **Warrior of God**: Righteous combat and protection
- **Scholar**: Knowledge of ancient texts and mysteries
- **Merchant**: Faith through commerce and trade
- **Pilgrim**: Balanced seeker, ideal for beginners

### **Rich Background System**
- Character origins affect starting bonuses and storylines
- Backgrounds include Commoner, Noble, Priest, Artisan, Shepherd
- Each background provides unique narrative opportunities

## 🛠️ Technical Implementation

### **Engine**: Godot 4.x
- **Language**: GDScript
- **Architecture**: Client-Server MMORPG
- **Networking**: Built-in Godot multiplayer system
- **Data**: JSON-based save system with local storage

### **Core Systems**
- **GameManager**: Central game state and moral choice coordination
- **NetworkManager**: Multiplayer connectivity and synchronization
- **PlayerData**: Character progression and persistent data
- **LegacySystem**: Generational tracking and family dynamics

## 📁 Project Structure

```
legacy-of-divinity/
├── project.godot           # Main project configuration
├── README.md              # This file
├── scripts/
│   ├── autoload/          # Singleton systems
│   │   ├── GameManager.gd
│   │   ├── NetworkManager.gd
│   │   ├── PlayerData.gd
│   │   └── LegacySystem.gd
│   ├── ui/                # User interface scripts
│   ├── player/            # Player character systems
│   ├── world/             # Game world scripts
│   └── networking/        # Network-specific code
├── scenes/
│   ├── main/              # Main menu and core scenes
│   ├── ui/                # UI scenes and dialogs
│   ├── world/             # Game world scenes
│   └── player/            # Player character scenes
├── assets/                # Game assets
│   ├── models/
│   ├── textures/
│   ├── audio/
│   └── fonts/
└── data/                  # Game data files
    ├── quests/
    ├── characters/
    └── items/
```

## 🚀 Getting Started

### **Prerequisites**
- Godot 4.2 or newer
- Basic understanding of GDScript (optional but helpful)

### **Installation**
1. Download and install [Godot 4.x](https://godotengine.org/download)
2. Clone or download this project
3. Open `project.godot` in Godot
4. Press F5 or click "Play" to run the project

### **First Run**
1. Start with "New Character" from the main menu
2. Choose your class and background
3. Enter the game world and test the moral choice system
4. Press 'C' in-game to trigger a test moral choice
5. Press 'H' to view family history (console)

## 🎯 Core Gameplay Loop

1. **Character Creation**: Choose class, background, and appearance
2. **Moral Choices**: Face dilemmas that shape your character
3. **Character Growth**: Gain experience, faith, and wisdom
4. **Death & Legacy**: Character dies, legacy carries to next generation
5. **New Generation**: Create descendant with ancestral bonuses
6. **Expanded World**: Previous choices affect available content

## 🔧 Development Roadmap

### **Phase 1: Foundation** ✅ *Current*
- [x] Basic project structure
- [x] Core autoload systems
- [x] Character creation system
- [x] Moral choice framework
- [x] Legacy tracking system
- [x] Basic networking foundation

### **Phase 2: Core Gameplay**
- [ ] Player movement and interaction
- [ ] Quest system with biblical narratives
- [ ] NPC dialogue system
- [ ] Inventory and item management
- [ ] Combat system (if applicable)

### **Phase 3: World Building**
- [ ] Biblical locations and environments
- [ ] Historical accuracy research integration
- [ ] Dynamic events based on player choices
- [ ] Community reputation system

### **Phase 4: Multiplayer**
- [ ] Server infrastructure
- [ ] Player interaction systems
- [ ] Guilds/communities ("Churches/Tribes")
- [ ] Persistent world events

### **Phase 5: Advanced Features**
- [ ] Advanced legacy mechanics
- [ ] Multi-generational questlines
- [ ] Historical timeline progression
- [ ] Educational content integration

## 📊 Current Systems Status

- ✅ **GameManager**: Core game state management
- ✅ **NetworkManager**: Basic multiplayer framework
- ✅ **PlayerData**: Character progression and persistence
- ✅ **LegacySystem**: Generational tracking and bonuses
- ✅ **MoralChoiceSystem**: Interactive moral decision making
- ✅ **Character Creation**: Class and background selection
- 🚧 **Game World**: Basic 3D environment (prototype)
- ❌ **Quest System**: Not yet implemented
- ❌ **Combat System**: Not yet implemented

## 🎮 Controls

- **WASD**: Movement (when implemented)
- **E**: Interact (when implemented)
- **I**: Inventory (when implemented)
- **C**: Test moral choice (current demo)
- **H**: Show family history (console)
- **ESC**: Return to main menu

## 🤝 Contributing

We welcome contributions from developers, historians, theologians, and gamers passionate about bringing biblical history to life through interactive entertainment.

### **How to Contribute**
- 🐛 Report bugs and issues
- 💡 Suggest features and improvements
- 📝 Contribute to documentation
- 🎨 Create assets (models, textures, sounds)
- 💻 Submit code improvements
- 📚 Research historical and biblical accuracy

### **Development Guidelines**
- Follow biblical and historical accuracy where possible
- Respect diverse religious perspectives
- Maintain clean, commented code
- Test thoroughly before submitting
- Document new features and systems

## 📜 Biblical Inspiration

This game draws inspiration from various biblical sources:
- **Old Testament**: Stories of faith, moral testing, generational consequences
- **New Testament**: Teachings on moral choices and their eternal impact
- **Apocryphal texts**: Additional historical and cultural context
- **Historical records**: Archaeological and historical accuracy

## ⚖️ Moral Framework

The game's moral system is based on:
- **Consequential Ethics**: Actions have lasting impacts
- **Virtue Ethics**: Character development through choices
- **Divine Command Theory**: Alignment with biblical principles
- **Natural Law**: Universal moral principles
- **Cultural Context**: Historical situational ethics

## 🔮 Vision Statement

*"To create an educational and entertaining experience that explores the depths of human morality, the consequences of our choices, and the legacy we leave for future generations, all within the rich tapestry of biblical history and human civilization."*

---

## 📞 Contact & Support

- **Project Lead**: [Your Name]
- **Repository**: [Your Repository URL]
- **Issues**: Please report bugs and feature requests via GitHub Issues
- **Discussions**: Use GitHub Discussions for community conversations

## 📄 License

This project is open source. Please respect the educational and religious nature of the content.

---

*"The choices we make echo in eternity..." - Legacy of Divinity*