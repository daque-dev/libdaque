module daque.graphics.color;

/++
	Struct representing an RGBA color
+/
struct Color
{
public:
    /++
		RGBA components of the color
	+/
    ubyte[4] component;

    /++
		Gets a reference to the Red component of the color
	+/
    ref ubyte r()
    {
        return component[0];
    }

    /++
		Gets a reference to the Green component of the color 
	+/
    ref ubyte g()
    {
        return component[1];
    }

    /++
		Gets a reference to the Blue component of the color
	+/
    ref ubyte b()
    {
        return component[2];
    }

    /++
		Gets a reference to the Alpha component of the color
	+/
    ref ubyte a()
    {
        return component[3];
    }

    /++
		Constructs a new Color from the given red (r), green (g), blue (b) and alpha (a) components
	+/
    this(ubyte r, ubyte g, ubyte b, ubyte a)
    {
        component[] = [r, g, b, a];
    }

    /++
		Constructs a color from the encoded 32 bit unsigned integer color
	+/
    this(uint color)
    {
        for (uint i; i < component.length; i++)
        {
            component[i] = color % 0x100;
            color >>= 8;
        }
    }

    /++
		Encodes the color into a 32 bit unsigned integer
	+/
    uint toInt()
    {
        uint color = 0u;

        for (int i = cast(int) component.length - 1; i >= 0; i--)
        {
            color += component[i];
            if (i - 1 >= 0)
                color <<= 8;
        }

        return color;
    }
}
