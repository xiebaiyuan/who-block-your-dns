#!/usr/bin/env python3
"""
Test script for custom rule sources feature
"""

import json
import os
import sys

# Add the backend directory to the path so we can import the main module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'backend-python'))

def test_load_additional_rule_sources():
    """Test the load_additional_rule_sources function"""
    # Create a test directory
    test_dir = "/tmp/test_rules"
    os.makedirs(test_dir, exist_ok=True)
    
    # Create a test JSON file
    test_config = [
        {
            "url": "https://example.com/test-rules.txt",
            "name": "Test Rules",
            "enabled": True
        }
    ]
    
    test_file = os.path.join(test_dir, "test_rules.json")
    with open(test_file, 'w') as f:
        json.dump(test_config, f)
    
    # Import the function
    from main import load下_additional_rule_sources
    
    # Test the function
    result = load_additional_rule_sources(test_dir)
    
    # Check the result
    assert len(result) == 1
    assert result[0]["url"] == "https://example.com/test-rules.txt"
    assert result[0]["name"] == "Test Rules"
    assert result[0]["enabled"] == True
    
    # Clean up
    os.remove(test_file)
    os.rmdir(test_dir)
    
    print("✅ load_additional_rule_sources test passed")

if __name__ == "__main__":
    test_load_additional_rule_sources()
    print("🎉 All tests passed!")