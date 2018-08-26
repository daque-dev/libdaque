module daque.graphics.glsl;

enum Type
{
    Float,
    Vec3,
    Vec4,
    Mat3
}

struct Declaration
{
    Type type;
    string identifier;
}

struct Input
{
    int location = -1;
    Declaration declaration;
    enum Normalized : bool
    {
        NORMALIZE = true, DONT_NORMALIZE = false
    }
    Normalized normalized;
}

string GetUniformPostfix(Type t)
{
    final switch(t)
    {
        case Type.Float:
            return "1fv";
        case Type.Vec3:
            return "3fv";
        case Type.Vec4:
            return "4fv";
        case Type.Mat3:
            return "Matrix3v";
    }
}

struct ProgramDescriptor
{
    ShaderDescriptor[] shaders;
}

struct ShaderDescriptor
{
    string glsl_version;
    Input[] inputs;
    Declaration[] uniforms;
    Declaration[] outputs;
    string source;
}

unittest
{
    import std.stdio;
    writeln("TESTING GLSL MODULE");
    ProgramDescriptor program_descriptor = 
    {
        shaders: [
            {
                glsl_version: "330 core",
                inputs: [
                    {0, {Type.Vec3, "in_position"}, Input.Normalized.DONT_NORMALIZE}, 
                    {1, {Type.Vec4, "in_color"}, Input.Normalized.NORMALIZE}
                ], 
                uniforms: [
                    {Type.Float, "z_near"},
                    {Type.Float, "z_far"},
                    {Type.Float, "alpha"},
                    {Type.Float, "xy_ratio"},
                    {Type.Vec3, "translation"}
                ],
                outputs: [
                    {Type.Vec4, "v_color"}
                ],
                source: q{
                    void main()
                    {
                        vec3 rotated = rotation * in_position;
                        vec3 translated = rotated + translation;
                        gl_Position = perspective;
                    }
                }
            }
        ]
    };
    writeln(program_descriptor);
}
