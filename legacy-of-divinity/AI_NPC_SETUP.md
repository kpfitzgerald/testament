# AI NPC Setup Guide for Testament: Legacy of Divinity

## Overview
Your biblical RPG now has AI-powered NPCs using OpenAI's GPT-4o-mini model. These NPCs can have dynamic, context-aware conversations based on their biblical character, personality, and secret knowledge.

## 🔑 API Key Setup

### Method 1: Environment Variable (Recommended)
1. Get your OpenAI API key from: https://platform.openai.com/api-keys
2. Set it as an environment variable:
   - **Windows**: `setx OPENAI_API_KEY "your-api-key-here"`
   - **PowerShell**: `$env:OPENAI_API_KEY = "your-api-key-here"`
3. Restart Godot after setting the environment variable

### Method 2: Direct Code Edit (Testing Only)
1. Open `scripts/autoload/AIDialogue.gd`
2. Find line with: `api_key = "PASTE_YOUR_OPENAI_API_KEY_HERE"`
3. Replace with your actual key: `api_key = "sk-your-actual-key-here"`

⚠️ **Security Warning**: Never commit your API key to version control!

## 🎭 Available AI NPCs

### Moses (MosesAI.tscn)
- **Era**: Exodus period (~1300 BC)
- **Personality**: Wise, humble leader chosen by God
- **Secret Knowledge**: Ten Commandments, burning bush, plagues of Egypt
- **Special Features**: Remembers speaking with God face-to-face

### Creating Custom AI NPCs
1. Use the `BiblicalAINPC.gd` script
2. Configure these key properties:
   - `npc_name`: Character's name
   - `physical_description`: How they look
   - `personality`: Character traits and behavior
   - `secret_knowledge`: Information they'll only share when asked
   - `biblical_era`: Time period they're from
   - `relationships`: Important connections to other characters

## 🎮 How to Use

### Adding NPCs to Your World
1. Open your GameWorld scene
2. Add an instance of `scenes/npc/MosesAI.tscn`
3. Position the NPC in your world
4. The NPC automatically handles interaction when players approach

### Player Interaction
1. Walk close to an AI NPC (within interaction radius)
2. Press **E** to start conversation
3. Type responses in the dialogue UI
4. The AI responds based on character personality and biblical knowledge

## 🔧 System Components

### Core Scripts
- `scripts/autoload/AIDialogue.gd` - Handles OpenAI API communication
- `scripts/npc/BiblicalAINPC.gd` - AI NPC behavior and interaction
- `scripts/autoload/DialogueSystem.gd` - Enhanced for AI integration

### Features
- **Context-Aware**: NPCs know their era, relationships, and environment
- **Biblical Accuracy**: Responses filtered for historical/religious authenticity
- **Secret Knowledge**: Special information revealed through conversation
- **Legacy Integration**: Can reference player's family history
- **Fallback System**: Traditional dialogue if AI unavailable

## 🎯 Biblical Character Examples

### High Priest Aaron
```gdscript
npc_name = "Aaron"
personality = "gentle priest, supportive brother to Moses, skilled in rituals"
secret_knowledge = "I know the proper way to enter the Holy of Holies and the meaning behind each priestly garment"
relationships = "Brother of Moses, father of Eleazar and Ithamar"
```

### Joshua
```gdscript
npc_name = "Joshua"
personality = "brave military leader, faithful follower of Moses, strategic mind"
secret_knowledge = "I scouted the Promised Land and saw the giants. I know the battle plans for Jericho."
relationships = "Student of Moses, leader of Israel's army"
```

## 🔄 Switching to Anthropic Claude

When ready to upgrade from OpenAI to Anthropic:

1. **Update API endpoint** in `AIDialogue.gd`:
   ```gdscript
   var url: String = "https://api.anthropic.com/v1/messages"
   ```

2. **Change headers**:
   ```gdscript
   var headers = ["Content-Type: application/json", "x-api-key: " + api_key, "anthropic-version: 2023-06-01"]
   ```

3. **Update request body format** (Claude uses different JSON structure)

## 🛟 Troubleshooting

### No AI Response
- Check API key is set correctly
- Verify internet connection
- Check Godot console for error messages

### Generic Responses
- Enhance the `physical_description` and `personality` fields
- Add more specific `secret_knowledge`
- Include relevant `relationships`

### Performance Issues
- Reduce `max_tokens` for faster responses
- Increase `temperature` for more variety (0.0-1.0)

## 💡 Advanced Features

### Dynamic Quest Generation
AI NPCs can create custom quests based on conversation context and player actions.

### Moral Choice Integration
Responses can reflect the player's previous moral choices and family legacy.

### Historical Accuracy
The system includes biblical context rules to maintain authentic period dialogue.

---

🎉 **Your biblical RPG now has living, breathing AI characters that can engage in meaningful conversations about faith, history, and the human condition!**