# Visual Effects Guide

## 🎯 **NEW: Attack Animations & Combat System**

### ⚔️ **Visual Attack System**
- **Golden Projectiles**: Cards create bright golden attack representations that fly toward targets
- **Arc Movement**: Attacks follow a realistic arc path with a midpoint 50px above the direct line
- **Rotation Effects**: Attack projectiles spin 720° (two full rotations) during flight
- **Scale Animation**: Projectiles grow larger then smaller during flight for dynamic feel
- **Glowing Trail**: Continuous color pulsing between bright yellow and golden orange
- **Flight Duration**: 1.0 second total (0.5s to arc peak, 0.5s to target)

### 💥 **Impact Effects**
- **Explosion Particles**: 15 particles in bright yellow, orange, red, and white
- **Outward Burst**: Particles explode in all directions from impact point
- **Variable Sizing**: Random particle sizes (4-12px) for realistic explosion look
- **Fade Animation**: Particles fade out over 0.3-0.8 seconds with scaling
- **Screen Shake**: 8 quick shakes with decreasing intensity for impact feel
- **Shake Pattern**: ±5px intensity reducing by 20% each shake

### 🎯 **Target Selection System**
- **Targeting Mode**: Activated automatically when cards execute
- **Enemy Highlighting**: All alive enemies glow bright yellow and pulse
- **Pulse Animation**: 0.3s cycles between yellow highlight and normal appearance
- **Selection Flash**: Chosen enemy flashes bright white briefly when clicked
- **Smart Filtering**: Only enemies with health > 0 can be targeted
- **Visual Reset**: All highlighting cleared after target selection

## ✅ ENHANCED FEATURES

### 🖱️ **Hover Animations** - FULLY FIXED (No Movement!)
- **Mouse Detection**: Works on entire card area with improved `mouse_filter` settings
- **Scale Effect**: 15% increase (enhanced from 10%)
- **Visual Effects**: Bright glow, card brought to front using z_index only
- **NO Position Changes**: Card stays perfectly in place, no sliding or movement
- **Transitions**: Smooth 0.15s animations with parallel tweening
- **Robustness**: Disabled during burning to prevent conflicts
- **Container Safety**: Uses z_index only, never modifies container order or position

### 🔥 **Burning Animation** - FULLY IMPLEMENTED (No Errors!)
- **4-Phase System**: Pre-ignition flash → Intense burning → Spark effects → Final fade
- **Duration**: 2.2 seconds total with dramatic progression
- **Fire Particles**: 20 enhanced particles with 8 realistic fire colors
- **Shake Effects**: 25 cycles with increasing intensity
- **Spark System**: 8 bright sparks flying from card edges
- **Progressive Burn**: Top-to-bottom destruction with realistic curling
- **Godot 4 Compatible**: All `tween_delay` replaced with `set_delay()`

### 🎯 **Click Feedback** - ENHANCED (No Errors!)
- **Scale Animation**: Quick compress (95%) then expand (105%)
- **Flash Effect**: Bright yellow-white glow
- **Timing**: 0.2s feedback before card effect triggers
- **Error-Free**: Fixed Godot 4 compatibility issues

---

## Card Rarity Effects

### 🏷️ **Common Cards**
- **Border**: Gray, 2px thick
- **Cost Panel**: Gray background
- **Effects**: No special animations

### 🟢 **Uncommon Cards**
- **Border**: Green, 3px thick
- **Cost Panel**: Green background
- **Effects**: Subtle green glow animation

### 🔵 **Rare Cards**
- **Border**: Blue, 4px thick
- **Cost Panel**: Blue background
- **Effects**: Blue shimmer effect

### 🟣 **Epic Cards**
- **Border**: Purple, 5px thick
- **Cost Panel**: Purple background
- **Effects**: Purple pulsing animation

### 🟠 **Legendary Cards**
- **Border**: Gold/Orange, 6px thick
- **Cost Panel**: Gold background
- **Effects**: Continuous golden glow animation

## Enemy Status Effects

### 🔥 **Burn Status**
- **Visual**: Flickering red-orange glow
- **Animation**: Fast pulsing between orange and red
- **Text Color**: Orange

### ❄️ **Frozen Status**
- **Visual**: Steady blue-white glow
- **Animation**: Slow pulsing blue effect
- **Text Color**: Light blue

### ☠️ **Poison Status**
- **Visual**: Pulsing green effect
- **Animation**: Green glow that fades in and out
- **Text Color**: Light green

### 🔮 **Other Status Effects**
- **Visual**: Purple pulsing
- **Animation**: Generic magical effect
- **Text Color**: Light purple

## Interactive Effects

### 🖱️ **Card Hover**
- Scale increases by 10%
- Slight brightening effect
- Smooth transition animations

### ⚡ **Damage Animation**
- Enemy flashes red
- Slight scale increase
- Quick return to normal

### 💚 **Healing Animation**
- Enemy flashes green
- Gentle scale pulse
- Smooth color transition

### 💀 **Death Animation**
- Gray out and fade
- Rotate 90 degrees
- Slow animation for dramatic effect

## UI Zones

### 🎯 **Enemy Zone** (Top)
- Red-themed background
- Contains enemy cards and health displays

### ⚔️ **Battlefield Zone** (Middle)
- **Blue-themed background**
- **Strategic card placement area**
- **Cards arrange left to right** in play order
- **Real-time counter** shows cards ready for execution
- **End Turn button** with dynamic state and card count
- **Visual progression** shows execution order clearly

### 🖐️ **Hand Zone** (Bottom)
- Green-themed background
- Contains player's cards with proper spacing

## Health Display

- **Healthy (>60%)**: Green text
- **Wounded (30-60%)**: Yellow text
- **Critical (<30%)**: Red text

## Card Interaction Flow

1. **In Hand**: Full size, hover effects, rarity animations, clickable
2. **Clicked**: Click feedback animation, then moves to battlefield
3. **In Battlefield**: 70% scale, grayed out, arranged left to right, not clickable
4. **Turn End**: Cards execute left to right with 1s delays
5. **Post-Execution**: Cards burn and disappear spectacularly

## 🎴 **Battlefield System** - NEW STRATEGIC GAMEPLAY!
- **Card Placement**: Smooth transition from hand to battlefield with visual feedback
- **Order Visualization**: Cards arrange left to right showing execution order
- **Scale & Color**: Battlefield cards at 70% size with subtle gray tint
- **Interactive UI**: Dynamic counter and button states provide clear feedback
- **Execution Flow**: Cards execute sequentially with 1s delays for dramatic effect
- **Strategic Planning**: Visual preview of turn before execution

## Tips for Expansion

- Add particle effects for legendary cards
- Implement card draw animations
- Add sound effects that match visual themes
- Create battlefield position effects
- Add turn-based visual indicators
