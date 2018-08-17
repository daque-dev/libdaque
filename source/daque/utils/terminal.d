/++
Authors:
	David Omar Flores Chávez (davidomarf), davidomarf@gmail.com
	Miguel Ángel (quevangel), quevangel@protonmail.com
+/

module daque.utils.terminal;

import std.traits;

enum TerminalColor: string
{
	Black =     "\033[0;30m",
	D_Gray =    "\033[1;30m",
	Red =       "\033[0;31m",
	L_Red =     "\033[1;31m",
	Green =     "\033[0;32m",
	L_Green =   "\033[1;32m",
	Brown =     "\033[0;33m",
	Yellow =    "\033[1;33m",
	Blue =      "\033[0;34m",
	L_Blue =    "\033[1;34m",
	Purple =    "\033[0;35m",
	L_Purple =  "\033[1;35m",
	Cyan =      "\033[0;36m",
	L_Cyan =    "\033[1;36m",
	L_Gray =    "\033[0;37m",
	White =     "\033[1;37m",
	NoColor =   "\033[0m"
}
