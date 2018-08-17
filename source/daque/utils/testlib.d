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


/++
	Tests the validity of a function @functionName and reports its
	results to the console.

	Every unittest in the source—code will create a	Tester.
+/
class Tester
{
public:
	/++ 
		Will only print the name of the function being tested.
	+/
	this(string functionName)
	{
		import std.stdio;
		writeln("\n--- ", functionName, " test ---");
	}
	~this()
	{

	}

	/++
		Compares two numeric values that are roughly equal, up to a
		default tolerance 1e-5.

		It uses std.math.approxEqual()
	+/
	void approx(alias func, ReturnType, InputTypes...)
		(InputTypes inputs, ReturnType expected)
			{
				
				// Compute the actual returned value
				ReturnType result = func(inputs);

				// Compare it against the known expected value and print
				// a successful or failure message accordingly.
				if(approxEqual(result, expected))
				{
					writeln(cast(string)TerminalColor.L_Green,
						__traits(identifier, func),
						"(", inputs, ") = ", expected);
				}
				else
				{
					writeln(cast(string)TerminalColor.Red,
						__traits(identifier, func),
						"(", inputs, ") = ", result, " != ", expected);
				}
				// Set non-colored text again
				write(cast(string)TerminalColor.NoColor);
			}
}
