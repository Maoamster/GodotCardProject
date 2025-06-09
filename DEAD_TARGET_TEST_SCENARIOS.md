# 🧪 Dead Target Handling - Test Scenarios

## **TEST CASE 1: Basic Dead Target Detection**

### Setup:
1. Start game with 3 enemies: Fire Goblin (15 HP), Ice Warrior (20 HP), Shadow Beast (12 HP)
2. Add Lightning Bolt (8 damage) to battlefield, assign target → Fire Goblin
3. Add Dragon's Fury (12 damage) to battlefield, assign target → Fire Goblin
4. Click "End Turn"

### Expected Results:
1. **Lightning Bolt executes first**: 
   - Output: `"🎯 Using pre-assigned target: Fire Goblin"`
   - Fire Goblin takes 8 damage (15 → 7 HP)
   
2. **Dragon's Fury executes second**:
   - Output: `"🎯 Using pre-assigned target: Fire Goblin"`
   - Fire Goblin takes 12 damage (7 → 0 HP, dies)
   
3. **If there was a third card assigned to Fire Goblin**:
   - Output: `"💀 Pre-assigned target Fire Goblin is dead - switching to random alive enemy"`
   - Output: `"🔄 Switched to random target: Ice Warrior"` (or Shadow Beast)

---

## **TEST CASE 2: Sequential Enemy Elimination**

### Setup:
1. Multiple weak enemies (reduce their HP to 1-2 each for testing)
2. Add 4 cards, all assigned to different enemies
3. Ensure some cards will kill their targets

### Expected Behavior:
- Cards that kill their targets work normally
- Cards assigned to enemies that died from previous cards automatically switch targets
- No crashes or invalid references
- Smooth execution flow continues

---

## **TEST CASE 3: Last Enemy Standing**

### Setup:
1. Reduce all enemies to very low HP (1-2 HP each)
2. Add multiple high-damage cards all assigned to different enemies
3. Execute turn where all but one enemy dies early

### Expected Result:
- First few cards kill their assigned targets normally
- Remaining cards automatically converge on the last alive enemy
- Output shows multiple `"🔄 Switched to random target: [Last Enemy]"` messages

---

## **TEST CASE 4: Total Enemy Defeat**

### Setup:
1. Only one enemy remaining with low HP
2. Add multiple cards, some assigned to that enemy
3. First card kills the last enemy

### Expected Result:
- First card executes and kills the enemy normally  
- Subsequent cards show: `"❌ No alive enemies found!"`
- No crashes, cards complete their execution cycle gracefully

---

## **DEBUGGING VERIFICATION**

### Watch Console Output:
- `🎯 Using pre-assigned target: [Enemy Name]` - Normal targeting
- `💀 Pre-assigned target [Enemy] is dead - switching to random alive enemy` - Dead detection
- `🔄 Switched to random target: [Enemy Name]` - Successful switch
- `❌ No alive enemies found!` - All enemies defeated

### Visual Verification:
- Cards still animate properly toward their final targets
- Impact effects occur on correct enemies
- Enemy health updates reflect actual damage dealt
- No visual glitches or frozen animations

---

## **INTEGRATION TEST**

### Complete Workflow:
1. **Planning Phase**: Assign multiple cards to specific enemies
2. **Execution Phase**: Click "End Turn" and watch automated execution
3. **Target Validation**: System automatically handles dead targets
4. **Visual Feedback**: All animations and effects work normally
5. **State Management**: Game continues normally after execution

### Success Criteria:
✅ No compilation errors
✅ No runtime crashes
✅ Smooth execution flow
✅ Correct target switching
✅ Clear debug output
✅ Visual effects work properly
✅ Game state remains consistent

**The dead target handling system provides robust, automatic target management that enhances the strategic gameplay experience while maintaining technical stability.**
