# StreetKings-inspired Chat

A compact FiveM roleplay chat built around the StreetKings visual language in your reference: a near-black base, signal-yellow accent (`#f5d336`), hard divider lines, uppercase white headings, compact metadata, and the same dense event-panel feel. The earlier sci-fi visual language has been removed.

## Install

1. Put `sk-streetchat` in your server's resources directory.
2. Add `ensure sk-streetchat` after your framework resources in `server.cfg`.
3. Remove or disable any other resource that binds `T` or replaces the native chat, then restart the server.

## Use

Press **T** to open local chat. A bare message is heard by players within 20 metres. Slash commands can be used from chat or directly in the F8 chat bar:

| Command | Scope | Purpose |
| --- | --- | --- |
| `/me message` | 20m | Character action |
| `/do message` | 20m | Scene detail |
| `/ooc message` | Server | Out-of-character message |
| `/g message` | Server | Global broadcast |
| `/twt message` | Server | Pulse/social post |

All distances, message colours, commands, history size, rate limiting, and the key binding are in `config.lua`. The resource is standalone: it deliberately does not require Qbox, ESX, ox_lib, or another chat package.

`/me` also places a yellow action bubble above the sender's head for seven seconds. It uses the same local radius as proximity chat, and its duration and character limit can be adjusted in `config.lua`.

## Notes

Server-side message length limits and a per-player cooldown are enforced. The browser interface escapes author names and message text before rendering, so users cannot inject markup into chat.
