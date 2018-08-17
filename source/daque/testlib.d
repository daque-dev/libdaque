/++
Authors:
    David Omar Flores Chávez (davidomarf), davidomarf@gmail.com
    Miguel Ángel (quevangel), quevangel@protonmail.com
+/

module daque.test;

import std.stdio;
import std.math;

string GREEN = "\033[1;32m";
string RED = "\033[1;31m";
string NOCOLOR = "\033[0m";

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
                    writeln(GREEN, __traits(identifier, func), "(", inputs, ") = ", expected);
                }
                else
                {
                    writeln(RED, __traits(identifier, func), "(", inputs, ") = ", result, " != ", expected);
                }
                write(NOCOLOR);
            }
}
