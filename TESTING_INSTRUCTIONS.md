# Testing Instructions for Enhanced Card Game

## 🎯 **NEW: Visual Attack System & Target Selection**

### **Strategic Battlefield Combat**
1. **Card Placement**: Click cards to move them to the blue battlefield zone
2. **Turn Execution**: Click "End Turn" to execute cards from left to right
3. **Target Selection**: 
   - When cards execute, you'll enter **TARGETING MODE**
   - All alive enemies will **glow yellow** and pulse to show they're targetable
   - **Click any enemy** to choose your target
   - Cards will **fly toward** the selected enemy with a spectacular animation
4. **Visual Combat**:
   - Watch cards create **golden attack projectiles** that arc toward targets
   - Enjoy **impact explosions** with particle effects when attacks hit
   - Experience **screen shake** effects for dramatic impact
   - See enemies **flash briefly** when selected as targets

### **Enhanced Enemy Interactions**
- **Multiple Enemies**: Fire Goblin (15 HP), Ice Warrior (20 HP), Shadow Beast (12 HP)
- **Smart Targeting**: Only alive enemies can be targeted
- **Visual Feedback**: Clear highlighting system for target selection
- **Attack Animations**: Cards fly in arcs with rotation and glowing trails
   - **No more "tween_delay" function errors**
   - Total duration: ~2.2 seconds per card

### 3. Visual Variety
**Test different rarities:**
- **Common** (gray): Ice Shard, Healing Potion
- **Uncommon** (green): Flame Imp, Poison Dart  
- **Rare** (blue): Lightning Bolt
- **Epic** (purple): Dragon's Fury
- **Legendary** (gold): Phoenix Rebirth

Each should have unique:
- Border colors and thickness
- Cost panel styling
- Idle animations (glow, pulse, shimmer)

## 🎯 **NEW BATTLEFIELD SYSTEM**

### **How It Works:**
1. **Play Cards**: Click cards in hand to move them to battlefield
2. **Plan Strategy**: Cards arrange left to right in battlefield
3. **Execute Turn**: Click "End Turn" to execute all cards in order
4. **Watch Effects**: Cards execute left to right with 1s delays
5. **Spectacular Finish**: Cards burn after execution

### **Visual Feedback:**
- **Hand Cards**: Full size, hoverable, clickable
- **Battlefield Cards**: 70% scale, grayed out, not clickable  
- **Battlefield Counter**: Shows number of cards ready "(3)"
- **End Turn Button**: Larger size (130x40px), disabled when no cards, shows "Executing..." during turn
- **Execution Order**: Clear left-to-right visual progression with proper timing

### **Strategic Gameplay:**
- Plan your card order carefully - leftmost cards execute first
- Build combinations by placing cards in specific order
- Battlefield provides visual preview of your turn before execution

## 🔧 Technical Features Tested

### Mouse Input System
- ✅ `mouse_filter = Control.MOUSE_FILTER_PASS` on main card
- ✅ `mouse_filter = Control.MOUSE_FILTER_IGNORE` on all children
- ✅ Recursive setup of child mouse filters
- ✅ Hover disabled during burning animation

### Animation System
- ✅ Parallel tweening for smooth effects
- ✅ Proper cleanup of animation objects
- ✅ No animation conflicts or memory leaks
- ✅ Position restoration after hover

### Burning Effects
- ✅ 4-phase progression system
- ✅ 20 enhanced fire particles with 8 colors
- ✅ Progressive top-to-bottom burning
- ✅ Spark effects from card edges
- ✅ Realistic curling and warping
- ✅ Proper cleanup after animation

## 🎮 User Experience

### Expected Feel:
1. **Responsive**: Immediate feedback on all interactions
2. **Smooth**: No stuttering or jarring transitions  
3. **Dramatic**: Burning animation feels spectacular
4. **Polished**: Professional-quality visual effects
5. **Consistent**: All cards behave predictably

### Performance:
- Should run smoothly on modern hardware
- No noticeable frame drops during animations
- Memory usage should remain stable

## 🐛 Potential Issues to Watch For

1. **Hover not working**: Check console for mouse filter messages
2. **Burning too slow/fast**: Timing can be adjusted in `start_burning_animation()`
3. **Particles not appearing**: Check if ColorRect nodes are being created
4. **Card stuck after burning**: Verify `queue_free()` is called

## 🎨 Customization Options

### Easy Tweaks:
- **Hover scale**: Change `1.15` in `_on_mouse_entered()`
- **Burn duration**: Adjust timing values in `start_burning_animation()`
- **Particle count**: Change `range(20)` in `create_enhanced_fire_particles()`
- **Shake intensity**: Modify values in `create_enhanced_burn_shake()`

### Advanced Modifications:
- Add sound effects in animation functions
- Create custom particle systems
- Implement different burning patterns per rarity
- Add explosion effects for legendary cards

---

**Happy Testing! 🎮✨**
