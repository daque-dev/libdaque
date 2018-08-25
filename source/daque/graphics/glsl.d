module daque.graphics.glsl;

enum Type
{
    Float,
    Vec3,
    Mat3
}

string GetUniformPostfix(Type t)
{
    final switch(t)
    {
        case Float:
            return "1fv";
        case Vec3:
            return "3fv";
        case Mat3:
            return "Matrix3v";
    }
}
