# Custom Rule Sources

This document explains how to add custom rule sources to the AdGuard DNS Query Service.

## Overview

The service supports loading additional rule sources from JSON configuration files placed in the rules directory. This allows you to extend the default rule sources with your own custom lists.

## Configuration Format

Custom rule sources are defined in JSON files with the following format:

### Single Rule Source
```json
{
  "url": "https://example.com/my-custom-rules.txt",
  "name": "My Custom Rules",
  "enabled": true
}
```

### Multiple Rule Sources
```json
[
  {
    "url": "https://example.com/my-custom-rules.txt",
    "name": "My Custom Rules",
    "enabled": true
  },
  {
    "url": "https://example.com/another-list.txt",
    "name": "Another Custom List",
    "enabled": false
  }
]
```

## Fields

- `url` (required): The URL of the rule list
- `name` (required): A descriptive name for the rule source
- `enabled` (optional): Whether the rule source should be enabled (default: true)

## File Naming

JSON configuration files should be placed in the rules directory and must have a `.json` extension. The filename can be anything you like, as long as it ends with `.json`.

## Docker Usage

### Development Environment

In the development environment, the rules directory is already mounted:

```yaml
volumes:
  - ./rules:/app/data/rules
```

Simply place your JSON configuration files in the `rules` directory, and they will be automatically loaded when the service starts.

### Production Environment

In production, you need to ensure the rules directory is properly mounted:

```yaml
volumes:
  - /path/to/your/rules:/app/data/rules
```

## Example

1. Create a JSON file `custom_rules.json`:

```json
[
  {
    "url": "https://raw.githubusercontent.com/your-username/your-repo/main/my-adblock-list.txt",
    "name": "My Personal AdBlock List",
    "enabled": true
  },
  {
    "url": "https://example.com/work-rules.txt",
    "name": "Work Environment Rules",
    "enabled": false
  }
]
```

2. Place the file in the rules directory

3. Restart the service (in development) or recreate the container (in production)

4. The new rule sources will be loaded and available in the UI

## Verification

You can verify that your custom rule sources have been loaded by:

1. Checking the application logs for messages like "加载额外规则源: My Personal AdBlock List from custom_rules.json"

2. Accessing the API endpoint `/api/rules/sources` to see all loaded rule sources

3. Using the frontend UI to view the rule sources list

## Best Practices

1. Use descriptive names for your rule sources to easily identify them

2. Disable rule sources that you don't want to use immediately, rather than removing them

3. Keep your JSON files organized and well-documented

4. Test your custom rule sources to ensure they work as expected

5. Regularly update your custom rule sources to get the latest rules

## Troubleshooting

If your custom rule sources are not loading:

1. Check that the JSON file is valid

2. Verify that the file is in the correct directory

3. Check the application logs for any error messages

4. Ensure the file has the correct `.json` extension

5. Make sure the URLs in your configuration are accessible