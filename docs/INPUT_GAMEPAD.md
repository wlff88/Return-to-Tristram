# RTT Gamepad Input

Xbox-class gamepads are a first-class input target for Return to Tristram.

## Goals

- same logical actions across DevilutionX and Abyss/D2-style runtime backends;
- Xbox button glyphs/layout when an Xbox 360/Xbox One/Xbox Series controller is detected;
- keyboard/mouse remains available in parallel;
- gameplay code consumes logical RTT actions, never SDL/XInput button numbers directly;
- remapping may be added without changing gameplay code.

## Default Xbox mapping

| Xbox control | RTT action |
|---|---|
| Left stick | Move character / UI navigation where appropriate |
| Right stick | Aim / target selection / cursor assist |
| A | Primary interact / confirm / basic action |
| B | Cancel / back |
| X | Primary skill/action |
| Y | Secondary skill/action |
| LB | Previous skill / modifier |
| RB | Next skill / modifier |
| LT | Hold-position / alternate modifier |
| RT | Primary attack / cast |
| D-pad | Belt/quick slots and menu navigation |
| View/Back | Automap |
| Menu/Start | Pause / game menu |
| LS click | Optional utility action |
| RS click | Optional target-lock / utility action |

The exact combat mapping can evolve during playtesting, but the backend-neutral action model is mandatory.

## DevilutionX

The pinned DevilutionX upstream already contains SDL gamepad support, detects Xbox 360/Xbox One-class devices as `GamepadLayout::Xbox`, and provides Xbox-specific button glyph mapping. RTT should reuse that native controller path and translate DevilutionX input/events to RTT logical actions rather than replacing SDL controller handling.

## Abyss / D2-style runtime

The Abyss backend must implement the same RTT logical action set. Platform-specific controller input (SDL Gamepad preferred for portability; XInput may be used as a Windows-specific fallback) stays behind the adapter.

## Runtime capability

Backends that support gamepad input advertise `RTT_RUNTIME_CAP_GAMEPAD` through `RttRuntimeInfo.capabilities`.

## Acceptance criteria

1. Xbox controller can navigate menus and start/continue a game without mouse input.
2. Player can move, attack/cast, interact, use quick slots, open automap, and navigate inventory/game menus.
3. UI shows Xbox glyphs when Xbox layout is active.
4. Hot-plugging a controller does not crash or corrupt input state.
5. Keyboard/mouse and controller can coexist.
6. Controller bindings are represented as logical RTT actions and do not leak engine-specific button IDs into RTT gameplay modules.
