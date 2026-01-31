# Fixit - NPC Vehicle Repair System

A standalone FiveM script that provides an immersive vehicle repair experience with NPC mechanics.

## Features

- **Interactive NUI Interface**: Clean, modern interface positioned in the top-right corner
- **Keybind Controls**:
  - `F4` - Open/Show the Fixit interface
  - `ESC` or `BACKSPACE` - Close the interface
- **Smart Repair System**: Automatically detects your current vehicle or finds the nearest one
- **Cooldown Protection**: 10-minute cooldown between repair calls to prevent abuse
- **Real-time Feedback**: Live countdown timer during cooldown period
- **RP Experience**: Mechanic drives to your location, performs repairs, and departs
- **Legacy Support**: Original `/fixit` chat command still available

## Installation

1. Download the `Fixit` folder
2. Place it in your server's `resources` directory
3. Add `start Fixit` to your `server.cfg`
4. Restart your server

## Usage

### NUI Interface (Recommended)
1. Press `F4` to open the Fixit interface
2. Click "Call For Repair" to summon a mechanic
3. The interface closes immediately and shows repair progress notifications
4. Wait for the mechanic to arrive and complete the repair

### Chat Command (Legacy)
- Type `/fixit` in chat to call for repair (same functionality)

## Cooldown System

- After calling for repair, you must wait 10 minutes before requesting service again
- The interface shows a live countdown timer (MM:SS format) during cooldown
- Attempting to call during cooldown displays the remaining time
- Cooldown resets when you rejoin the server

## Configuration

Edit `config.lua` to customize:
- Spawn distances for the tow truck
- Vehicle and ped models
- Driving speed
- Blip settings

## Notifications

The system provides clear feedback through:
- Chat notifications for repair status
- In-game NUI messages for cooldown information
- Visual blips on the map for the approaching tow truck

## Dependencies

- None (standalone script)

## Support

This is a standalone script that works with any framework or no framework at all.

## Credits

Original script by Cowboy, enhanced with NUI interface and cooldown system.
