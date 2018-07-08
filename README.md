# AFBase
AFB is based on AdminFuckery2 -- most of the commands have been ported over.
This plugin allows server owners to easily setup access flags for admins & install expansions to the plugin (AMX-like functionality), it also allows for scripters to make more commands really fast.

## Quick installation guide:
1. download the repo
2. extract to /svencoop_addons/ or /svencoop/ folder
(if you extracted to svencoop_addons): move contents from svencoop_addons/scripts/plugins/store/ to svencoop/scripts/plugins/store/)
3. insert AFBase into default_plugins.txt:
```
    "plugin"
    {
        "name" "AFBase"
        "script" "AFBase"
    }  
```
4. open up AFBaseAccess.txt
5. add your steamid with  the flag B or alternatively give yourself all the flags
6. as_reloadplugins & changelevel
7. (optional): if you didint give yourself all the flags in step 5, run this command: .afb_access @me "+cdefghijklmnopqrstuvwyx"
8. done!

## for scripters:
"documentation" for extension scripting available [here](https://zode.github.io/AFBase/)

## Other stuff:
use ".afb_help" to view all available commands!

these commands are always available to everyone:
```
.afb_help
.afb_who (wont show ip unless user has any flag from A to Y)
.afb_info
.afb_listextensions
```

Here is a full list of stock commands:
```
] .afb_help
----AdminFuckeryBase help: Command list-----------------------------------------
Quick quide: (arg) required parameter, <arg> optional parameter. Targets: @all, @admins, @noadmins, @alive
 @dead, @aim, @random, @last, @me, "nickname" (supports * wildcard), "STEAM_0:1:ID"
--------------------------------------------------------------------------------
 1: .admin_ban ("steamid") <"reason"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid> - ban target
 2: .admin_banlate ("steamid/ip") <"reason"> <duration in minutes, 0 for infinite> - late ban target, basically adds to ban list. Doesn't validate player like admin_ban does.
 3: .admin_blockdecals (target) (0/1 unban/ban) - Ban target from spraying
 4: .admin_changelevel (level) - change level
 5: .admin_gag (targets) (mode a/c/v) - gag player, a = all, c = chat, v = voice
 6: .admin_kick (target) <"reason"> - kicks target with reason
 7: .admin_rcon (command) - remote console
 8: .admin_say (0/1 showname) (0/1/2 chat/hud/middle) ("text") <holdtime> <target> <r> <g> <b> <x> <y> - say text
 9: .admin_slap (target) <damage> - slap target(s)
 10: .admin_slay (target) - slay target(s)
 11: .admin_trackdecals <0/1 mode> - track player sprays, don't define mode to toggle
 12: .admin_unban ("steamid or ip") - unban target
 13: .admin_ungag (targets) - ungag player
 14: .afb_access (target) <accessflags> - get/set accessflags, add + or - before flags to add or remove
 15: .afb_disconnected <0/1 don't shorten nicks> - Show recently disconnected client information
 16: .afb_extension_start ("extension SID") - start extension
 17: .afb_extension_stop ("extension SID") - stop extension
 18: .afb_help <page> <0/1 show expansion> - List available commands
 19: .afb_info - Show info
 20: .afb_last <0/1 don't shorten nicks> - (alias for afb_disconnected) Show recently disconnected client information
 21: .afb_listextensions - List extensions
 22: .afb_menu - pop open a simple command menu
 23: .afb_peek (targets) - peeks into internal AFB info
 24: .afb_setlast (target) - sets last target, use if you only want to select somebody without running a command on them
 25: .afb_who <0/1 don't shorten nicks> - Show client information
 26: .ent_create (classname) <"key:value:key:value:key:value" etc> - create entity, default position at your origin
 27: .ent_damage <damage> <targetname> - damage entity, if no targetname given it will attempt to trace forwards
 28: .ent_drop - Drop entity that you are aiming at to ground
 29: .ent_dumpinfo <dirty 0/1> <targetname> - dump entity keyvalues into console, if no targetname given it will attempt to trace forwards
 30: .ent_item (weapon_/ammo_/item_ name) - Spawn weapon/ammo/item at your location
 31: .ent_keyvalue (key) <value> <value> <value> - get/set keyvalue of entity you are aiming at, use "!null!" to set keyvalue as empty
 32: .ent_keyvaluename (targetname) (key) <value> <value> <value> - get/set keyvalue of entity based on targetname, use "!null!" to set keyvalue as empty
 33: .ent_keyvaluerange (classname) (range) (key) <value> <value><value> - get/set keyvalue of entity based on classname and range, use "!null!" to set keyvalue as empty
 34: .ent_kill <targetname> - removes entity, if no targetname given it will attempt to trace forwards
 35: .ent_move - Use without argument to see usage/alias - Grab entity and move it relative to you
 36: .ent_movecopy - Use without argument to see usage/alias - Copy & grab (copied) entity and move it relative to you
 37: .ent_movename (targetname) - absolute move, entity is placed to your origin
 38: .ent_mover <0/1 mode> - weapon_entmover, don't define mode to toggle
 39: .ent_rotate (x) (y) (z) <targetname> - rotate entity, if no targetname given it will attempt to trace forwards. For best results use 15 increments
 40: .ent_rotateabsolute (x) (y) (z) <targetname> - set entity rotation, if no targetname given it will attempt to trace forwards
 41: .ent_trigger <targetname> - trigger entity, if no targetname given it will attempt to trace forwards
 42: .ent_triggerrange (classname) (range) - trigger entity based on classname and range
 43: .ent_worldcopy (speed) <angle vector> <0/1 reverse> <0/1 xaxis> <0/1 yaxis> - Create worldcopy
 44: .ent_worldremove - Remove all worldcopies
 45: .fun_fade (targets) <r> <g> <b> <fadetime> <holdtime> <alpha> <flags> - fade target(s) screens!
 46: .fun_gibhead (targets) - GIBS!!! Spawns head gib on target(s)!
 47: .fun_gibrand (targets) <amount> - GIBS!!! Spawns random gibs on target(s)!
 48: .fun_maplight (character from A (darkest) to Z (brightest), M returns to normal) - set map lighting!
 49: .fun_shake <amplitude> <frequency> <duration> - shake everyone's screen!
 50: .fun_shootgrenade <velocitymultipier> <time> - shoot grenades!
 51: .fun_shootportal <damage> <radius> <velocity> - shoot portals!
 52: .fun_shootrocket <velocity> - shoot normal RPG rockets!
 53: .player_disarm (targets) - disarm target(s)
 54: .player_dumpinfo (targets) <dirty 0/1> - dump player keyvalues into console
 55: .player_exec (targets) ("command") - execute command on client console
 56: .player_freeze (targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle
 57: .player_getmodel (targets) - return target(s) playermodel
 58: .player_give (targets) (weapon/ammo/item) - give target(s) stuff
 59: .player_giveall (targets) - give target(s) all stock weapons
 60: .player_giveammo (targets) - give target(s) ammo
 61: .player_givemapcfg (targets) - apply map cfg to target(s)
 62: .player_god (targets) <0/1 mode> - set target(s) godmode, don't define mode to toggle
 63: .player_ignite (targets) - ignite target(s)
 64: .player_keyvalue (targets) (key) <value> <value> <value> - get/set target(s) keyvalue
 65: .player_noclip (targets) <0/1 mode> - set target(s) noclip mode, don't define mode to toggle
 66: .player_nosolid (targets) <0/1 mode> - set target(s) solidity, don't define mode to toggle
 67: .player_notarget (targets) <0/1 mode> - set target(s) notarget, don't define mode to toggle
 68: .player_position (target) - returns target position,
 69: .player_resurrect (targets) <0/1 no respawn> - resurrect target(s)
 70: .player_setmaxspeed (targets) (speed) - set target(s) max speed
 71: .player_tag <targets> <tag> - tag target, visible only for admins. Run without arguments to view list
 72: .player_tagfix - refresh tags on your view, in case something fucks up
 73: .player_teleportaim (targets) - teleport target(s) to where you are aiming at
 74: .player_teleportmeto (target) - teleport you to target
 75: .player_teleportpos (targets) (vector) - teleport target(s) to position
 76: .player_teleporttome (targets) - teleport target(s) to you
 77: .player_viewmode (targets) (0/1 firstperson/thirdperson) - set target(s) viewmode
 78: say !freeze (targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle
 79: say !give (targets) (weapon/ammo/item) - give target(s) stuff
 80: say !giveammo (targets) - give target(s) ammo
 81: say !nosolid (targets) <0/1 mode> - set target(s) nosolid mode, don't define mode to toggle
 82: say !resurrect (targets) <0/1 no respawn> - resurrect target(s)
 83: say !tag <targets> <tag> - tag target, visible only for admins. Run without arguments to view list
 84: say !tagfix - refresh tags on your view, in case something fucks up
 85: say !tpaim (targets) - teleport target(s) to where you are aiming at
 86: say !tpmeto (target) - teleport you to target
 87: say !tptome (targets) - teleport target(s) to you
--------------------------------------------------------------------------------
[AFB] showing page 9 of 9.
```