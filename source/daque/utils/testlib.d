/++
Authors:
    David Omar Flores Chávez (davidomarf), davidomarf@gmail.com
    Miguel Ángel (quevangel), quevangel@protonmail.com
+/

module daque.utils.test;

import std.stdio;
import std.math;
import std.traits;

import daque.utils.terminal;

class Tester
{
    public:
        this(string functionName)
        {
            import std.stdio;
            writeln("\n--- ", functionName, " test ---");
        }
        ~this()
        {

        }

    void approx(alias func, ReturnType, InputTypes...)
        (InputTypes inputs, ReturnType expected)
            {
                ReturnType result = func(inputs);
                if(approxEqual(result, expected))
                {
                    writeln(cast(string)TerminalColor.L_Green, __traits(identifier, func), "(", inputs, ") = ", expected);
                }
                else
                {
                    writeln(cast(string)TerminalColor.Red, __traits(identifier, func), "(", inputs, ") = ", result, " != ", expected);
                }
                write(cast(string)TerminalColor.NoColor);
            }
}
