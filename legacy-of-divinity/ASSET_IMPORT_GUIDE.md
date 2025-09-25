# Legacy of Divinity - Asset Import Guide

## Biblical Asset Priority List

### 🏛️ **High Priority - Biblical Architecture**
1. **Ancient Temple** (`ancienttemple.zip`)
   - Solomon's Temple recreations
   - Synagogues and worship spaces
   - Sacred courtyards and altars

2. **Ancient Ruins** (`ancientruins.zip`)
   - Archaeological biblical sites
   - Destroyed cities (Babylon, Nineveh)
   - Ancient walls and foundations

3. **Arabian Palace** (`arabianpalace.zip`)
   - Middle Eastern royal courts
   - Persian/Babylonian palaces
   - Rich architectural details

### 🏘️ **Medium Priority - Settlements**
4. **Medieval Town/Village**
   - Biblical-era cities (Jerusalem, Bethlehem)
   - Market squares and residential areas
   - Modular building system

### 🌲 **Environment Assets**
5. **Fantasy Forest** - Wilderness journeys
6. **Tents** - Nomadic camps, Abraham's travels

---

## Godot Import Workflow

### Step 1: Extract Assets
Run the setup script:
```powershell
.\setup_assets.ps1
```

### Step 2: Import 3D Models
1. Copy `.fbx` files to `assets/models/biblical/`
2. In Godot: **Import tab → Select .fbx → Import**
3. Settings to check:
   - ✅ Create Materials
   - ✅ Import Animations (if any)
   - ✅ Optimize for Size

### Step 3: Import Textures
1. Copy texture files to `assets/textures/biblical/`
2. Supported formats: `.png`, `.jpg`, `.tga`, `.exr`
3. Godot auto-imports on file add

### Step 4: Create Materials
1. **Scene tab → Create Material Resource**
2. Assign textures:
   - **Albedo** → Diffuse/Color map
   - **Normal** → Normal map
   - **Roughness** → Roughness map
   - **Metallic** → Metallic map

### Step 5: Build Biblical Scenes
1. Create scene: `File → New Scene → 3D Scene`
2. Add imported models as children
3. Apply materials
4. Save as `.tscn` in `assets/scenes/biblical/`

---

## Biblical Scene Ideas

### 🏛️ **Temple Complex**
- **Solomon's Temple** - Main worship center
- **Court of Gentiles** - Outer courtyard
- **Holy of Holies** - Sacred inner chamber

### 🏙️ **Ancient Jerusalem**
- **City Walls** - Defensive fortifications
- **Market Streets** - Trade and commerce
- **Residential Quarters** - Living areas

### 🏕️ **Nomadic Camps**
- **Abraham's Encampment** - Patriarchal tents
- **Israelite Camp** - Wilderness wanderings
- **Trading Caravans** - Commercial routes

### 🏛️ **Royal Palaces**
- **David's Palace** - Jerusalem royal court
- **Babylonian Palace** - Exile period
- **Persian Court** - Post-exile era

---

## Asset Conversion Tips

### From Unreal to Godot:
- **Materials**: May need recreation
- **Lighting**: Will need adjustment
- **Scale**: Check model sizing (Godot units)
- **Textures**: Usually transfer directly

### Optimization:
- **LOD Models**: Use lower poly versions for distance
- **Texture Compression**: Enable in import settings
- **Culling**: Set up proper collision and visibility

### Biblical Authenticity:
- **Architecture**: Research historical accuracy
- **Materials**: Stone, wood, fabric textures
- **Colors**: Earth tones, natural pigments
- **Scale**: Human-appropriate proportions

---

## Next Steps After Import

1. **Create Biblical Locations**: Build key scenes
2. **Test Performance**: Ensure good frame rates
3. **Add Gameplay**: NPCs, quests, moral choices
4. **Biblical Events**: Recreate scriptural scenes
5. **Generational Impact**: How choices affect descendants