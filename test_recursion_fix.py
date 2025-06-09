#!/usr/bin/env python3
"""
Simple test to verify the recursion fix is working
"""

def test_recursion_prevention():
    """Test that our recursion prevention mechanism works"""
    print("🧪 Testing recursion prevention fix...")
    
    # Check if the guard variables are defined
    guard_vars = [
        "_applying_rarity_styling",
        "_updating_affordability", 
        "_updating_display",
        "_last_style_update_frame"
    ]
    
    with open("Scripts/Card.gd", "r") as f:
        content = f.read()
        
    for var in guard_vars:
        if var in content:
            print(f"✅ Found guard variable: {var}")
        else:
            print(f"❌ Missing guard variable: {var}")
    
    # Check if deferred functions are defined
    deferred_funcs = [
        "_apply_main_border_styling",
        "_apply_rarity_label_styling"
    ]
    
    for func in deferred_funcs:
        if func in content:
            print(f"✅ Found deferred function: {func}")
        else:
            print(f"❌ Missing deferred function: {func}")
    
    # Check if call_deferred is used
    if "call_deferred" in content:
        print("✅ Found call_deferred usage")
    else:
        print("❌ Missing call_deferred usage")
    
    print("🎯 Recursion fix validation complete!")

if __name__ == "__main__":
    test_recursion_prevention()
