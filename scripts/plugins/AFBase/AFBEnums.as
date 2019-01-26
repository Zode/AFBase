enum AccessLevels
{
	ACCESS_Z = 1, // default access, plugin info / expansion info, help command, who command
	ACCESS_Y = 2, // custom access 17
	ACCESS_X = 4, // custom access 16
	ACCESS_W = 8, // custom access 15
	ACCESS_V = 16, // custom access 14
	ACCESS_U = 32, // custom access 13
	ACCESS_T = 64, // custom access 12
	ACCESS_S = 128, // custom access 11
	ACCESS_R = 256, // custom access 10
	ACCESS_Q = 512, // custom access 9
	ACCESS_P = 1024, // custom access 8
	ACCESS_O = 2048, // custom access 7
	ACCESS_N = 4096, // custom access 6
	ACCESS_M = 8192, // custom access 5
	ACCESS_L = 16384, // custom access 4
	ACCESS_K = 32768, // custom access 3
	ACCESS_J = 65536, // custom access 2
	ACCESS_I = 131072, // custom access 1
	ACCESS_H = 262144, // fun_ commands, say
	ACCESS_G = 524288, // player_ commands, player quickmenu, slap, slay, trackdecals
	ACCESS_F = 1048576, // ent_ commands
	ACCESS_E = 2097152, // kick, changelevel, "highrisk"
	ACCESS_D = 4194304, // ban/unban
	ACCESS_C = 8388608, // rcon
	ACCESS_B = 16777216, // set access, stop/start expansion
	ACCESS_A = 33554432 // immunity
}

enum PlayerTargeters
{
	TARGETS_NOALL = 1,
	TARGETS_NOME = 2,
	TARGETS_NODEAD = 4,
	TARGETS_NOAIM = 8,
	TARGETS_NORANDOM = 16,
	TARGETS_NOLAST = 32,
	TARGETS_NONICK = 64,
	TARGETS_NOIMMUNITYCHECK = 128,
	TARGETS_NOALIVE = 256
}

enum CommandExtras
{
	CMD_PRECACHE = 1,
	CMD_SUPRESS = 2,
	CMD_SERVER = 4,
	CMD_SERVERONLY = 8
}