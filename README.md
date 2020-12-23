# AFBase
AFB is based on AdminFuckery2 -- most of the commands have been ported over.
This plugin allows server owners to easily setup access flags for admins & install expansions to the plugin (AMX-like functionality), it also allows for scripters to make more commands really fast.

## Quick installation guide:
1. download the repo
2. extract to /svencoop_addons/ or /svencoop/ folder
(if you extracted to svencoop_addons: move contents from svencoop_addons/scripts/plugins/store/ to svencoop/scripts/plugins/store/)
3. insert AFBase into default_plugins.txt:
```
    "plugin"
    {
        "name" "AFBase"
        "script" "AFBase"
    }  
```
4. open up AFBaseAccess.txt
5. Do either of these methods.

Method A
1. add your steamid with  the flag B or alternatively give yourself all the flags
2. as_reloadplugins & changelevel
3. (optional): if you didn't give yourself all the flags in step 5, run this command: .afb_access @me "+cdefghijklmnopqrstuvwyx"
4. done!

Method B
1. connect to your server
2. in your svends server console, run: as_command .s_afb_access "NICKNAME OR STEAMID HERE" "+bcdefghijklmnopqrstuvwyx"
3. done!

## for scripters:
"documentation" for extension scripting available [here](https://zode.github.io/AFBase/)

## for users:
(new in 1.5.0) wildcarding works now from start, and both ways. You can use \*mpleUser, \*mple\* or Example\* to target "ExampleUser". Wildcards that result in multiple players wont be executed anymore.

random values in keyvalue fields: you can use r#A-B to select a random value, for example: .player_keyvalue @me health r#30-60 would set your health to a random value between 30 and 60.

svends server console can now issue AFB commands, syntax: as_command .s_(command), example: as_command .s_afb_help (prefix is needed due to AS implementation not allowing client/server command to exist with the same name, it is automatically added to any server command registered)

(new in 1.5.0) cvar to bypass access file for those who want the system to behave in a binary way (is admin, or isnt admin): .afb_access_ignore 0/1, by default this value is 0 and AFB will use the access file.

Keep an eye in this space, i might have forgotten something and might update this later :)

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
 1: admin_ban ("steamid") <"reason"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid> - ban target
 2: admin_banlate ("steamid/ip") <"reason"> <duration in minutes, 0 for infinite> - late ban target, basically adds to ban list. Doesn't validate player like admin_ban does.
 3: admin_blockdecals (target) (0/1 unban/ban) - Ban target from spraying
 4: admin_changelevel (level) - change level
 5: admin_gag (targets) (mode a/c/v) - gag player, a = all, c = chat, v = voice
 6: admin_kick (target) <"reason"> - kicks target with reason
 7: admin_rcon (command) <noquotes 0/1> - remote console
 8: admin_say (0/1 showname) (0/1/2 chat/hud/middle) ("text") <holdtime> <target> <r> <g> <b> <x> <y> - say text
 9: admin_slap (target) <damage> - slap target(s)
 10: admin_slay (target) - slay target(s)
 1: admin_ban ("steamid") <"reason"> <duration in minutes, 0 for infinite> <0/1 ban ip instead of steamid> - ban target
 2: admin_banlate ("steamid/ip") <"reason"> <duration in minutes, 0 for infinite> - late ban target, basically adds to ban list. Doesn't validate player like admin_ban does.
 3: admin_blockdecals (target) (0/1 unban/ban) - Ban target from spraying
 4: admin_changelevel (level) - change level
 5: admin_gag (targets) (mode a/c/v) - gag player, a = all, c = chat, v = voice
 6: admin_kick (target) <"reason"> - kicks target with reason
 7: admin_rcon (command) <noquotes 0/1> - remote console
 8: admin_say (0/1 showname) (0/1/2 chat/hud/middle) ("text") <holdtime> <target> <r> <g> <b> <x> <y> - say text
 9: admin_slap (target) <damage> - slap target(s)
 10: admin_slay (target) - slay target(s)
 11: admin_trackdecals <0/1 mode> - track player sprays, don't define mode to toggle
 12: admin_unban ("steamid or ip") - unban target
 13: admin_ungag (targets) - ungag player
 14: afb_access (target) <accessflags> - get/set accessflags, add + or - before flags to add or remove
 15: afb_disconnected <0/1 don't shorten nicks> - Show recently disconnected client information
 16: afb_expansion_list - List expansions
 17: afb_expansion_start ("expansion SID") - start expansion
 18: afb_expansion_stop ("expansion SID") - stop expansion
 19: afb_help <page> <0/1 show expansion> - List available commands
 20: afb_info - Show info
 21: afb_last <0/1 don't shorten nicks> - (alias for afb_disconnected) Show recently disconnected client information
 22: afb_menu - pop open a simple command menu
 23: afb_peek (targets) - peeks into internal AFB info
 24: afb_setlast (target) - sets last target, use if you only want to select somebody without running a command on them
 25: afb_whatsnew - show changelog for this version
 26: afb_who <0/1 don't shorten nicks> - Show client information
 27: ent_bbox <r> <g> <b> <lifetime> - show the ent's bounding box
 28: ent_bboxname (targetname) <r> <g> <b> <lifetime> - show the specified ent's bounding box
 29: ent_create (classname) <"key:value:key:value:key:value" etc> - create entity, default position at your origin
 30: ent_damage <damage> <targetname> - damage entity, if no targetname given it will attempt to trace forwards
 31: ent_drop - Drop entity that you are aiming at to ground
 32: ent_dumpinfo <dirty 0/1> <targetname> - dump entity keyvalues into console, if no targetname given it will attempt to trace forwards
 33: ent_grid (gridsize) - set a grid for snapping, 0 to disable
 34: ent_item (weapon_/ammo_/item_ name) - Spawn weapon/ammo/item at your location
 35: ent_keyvalue (key) <value> <value> <value> - get/set keyvalue of entity you are aiming at, use "!null!" to set keyvalue as empty
 36: ent_keyvaluename (targetname) (key) <value> <value> <value> - get/set keyvalue of entity based on targetname, use "!null!" to set keyvalue as empty
 37: ent_keyvaluerange (classname) (range) (key) <value> <value><value> - get/set keyvalue of entity based on classname and range, use "!null!" to set keyvalue as empty
 38: ent_kill <targetname> - removes entity, if no targetname given it will attempt to trace forwards
 39: ent_move - Use without argument to see usage/alias - Grab entity and move it relative to you
 40: ent_movecopy - Use without argument to see usage/alias - Copy & grab (copied) entity and move it relative to you
 41: ent_movename (targetname) - absolute move, entity is placed to your origin
 42: ent_mover <0/1 mode> - weapon_entmover, don't define mode to toggle
 43: ent_rotate (x) (y) (z) <targetname> - rotate entity, if no targetname given it will attempt to trace forwards. For best results use 15 increments
 44: ent_rotateabsolute (x) (y) (z) <targetname> - set entity rotation, if no targetname given it will attempt to trace forwards
 45: ent_rotatefix <targetname> - attempt to reset originless brush to default position
 46: ent_show (x/y/z) - show world direction
 47: ent_trigger <targetname> - trigger entity, if no targetname given it will attempt to trace forwards
 48: ent_triggerrange (classname) (range) - trigger entity based on classname and range
 49: ent_worldcopy (speed) <angle vector> <0/1 reverse> <0/1 xaxis> <0/1 yaxis> - Create worldcopy
 50: ent_worldremove - Remove all worldcopies
 51: fun_conc (targets) (amplitude) (frequency) (fadetime) - CoNcUsSiOn!
 52: fun_fade (targets) <r> <g> <b> <fadetime> <holdtime> <alpha> <flags> - fade target(s) screens!
 53: fun_flash (targets) <0/1> - toggle or set target(s) flashlight
 54: fun_fog (targets) (r) <g> <b> <start> <end> - set level fog, supply target(s) and -1 to disable
 55: fun_gibhead (targets) - GIBS!!! Spawns head gib on target(s)
 56: fun_gibrand (targets) <amount> - GIBS!!! Spawns random gibs on target(s)
 57: fun_maplight (character from A (darkest) to Z (brightest), M returns to normal) - set map lighting
 58: fun_shake <amplitude> <frequency> <duration> - shake everyone's screen!
 59: fun_shootgrenade <velocitymultipier> <time> - shoot grenades
 60: fun_shootportal <damage> <radius> <velocity> - shoot portals
 61: fun_shootrocket <velocity> - shoot normal RPG rockets
 62: player_disarm (targets) <weapon> - disarm target(s), don't define weapon to disarm everything
 63: player_dumpinfo (targets) <dirty 0/1> - dump player keyvalues into console
 64: player_exec (targets) ("command") <noquotes 0/1> - execute command on client console
 65: player_freeze (targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle
 66: player_getmodel (targets) - return target(s) playermodel
 67: player_give (targets) (weapon/ammo/item) - give target(s) stuff
 68: player_giveall <targets> <set> - give target(s) all stock weapons, don't define target to view all currently possible sets, set defaults to vanilla
 69: player_giveammo (targets) <0/1 all> - give target(s) ammo, defaults to all weapons
 70: player_givemapcfg (targets) - apply map cfg to target(s)
 71: player_god (targets) <0/1 mode> - set target(s) godmode, don't define mode to toggle
 72: player_ignite (targets) - ignite target(s)
 73: player_keyvalue (targets) (key) <value> <value> <value> - get/set target(s) keyvalue
 74: player_maxspeed (targets) (speed) - set target(s) max speed, -1 to restore to default
 75: player_noclip (targets) <0/1 mode> - set target(s) noclip mode, don't define mode to toggle
 76: player_nosolid (targets) <0/1 mode> - set target(s) solidity, don't define mode to toggle
 77: player_notarget (targets) <0/1 mode> - set target(s) notarget, don't define mode to toggle
 78: player_position (target) - returns target position,
 79: player_resurrect (targets) <0/1 no respawn> - resurrect target(s)
 80: player_tag <targets> <tag> - tag target, visible only for admins. Run without arguments to view list
 81: player_tagfix - refresh tags on your view, in case something fucks up
 82: player_teleportaim (targets) - teleport target(s) to where you are aiming at
 83: player_teleportmeto (target) - teleport you to target
 84: player_teleportpos (targets) (vector) - teleport target(s) to position
 85: player_teleporttome (targets) - teleport target(s) to you
 86: player_viewmode (targets) (0/1 firstperson/thirdperson) - set target(s) viewmode
 87: say !freeze (targets) <0/1 mode> - freeze/unfreeze target(s), don't define mode to toggle
 88: say !give (targets) (weapon/ammo/item) - give target(s) stuff
 89: say !giveammo (targets) <0/1 all> - give target(s) ammo, defaults to all weapons
 90: say !nosolid (targets) <0/1 mode> - set target(s) nosolid mode, don't define mode to toggle
 91: say !resurrect (targets) <0/1 no respawn> - resurrect target(s)
 92: say !tag <targets> <tag> - tag target, visible only for admins. Run without arguments to view list
 93: say !tagfix - refresh tags on your view, in case something fucks up
 94: say !tpaim (targets) - teleport target(s) to where you are aiming at
 95: say !tpmeto (target) - teleport you to target
 96: say !tptome (targets) - teleport target(s) to you
--------------------------------------------------------------------------------
[AFB] showing page 10 of 10.
```