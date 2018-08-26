module daque.graphics.glsl;

enum Type
{
    Float,
    Vec3,
    Vec4,
    Mat3
}

string Type_to_dlang_type(Type type)
{
    final switch(type)
    {
        case Type.Float:
            return "float";
        case Type.Vec3:
            return "float[3]";
        case Type.Vec4: 
            return "float[4]";
        case Type.Mat3:
            assert(0, "Mat3 has no Dlang Type analog");
    }
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

string Get_uniform_postfix(Type t)
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

enum ProgramDescriptor program_descriptor = 
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

template VertexType(ProgramDescriptor PROGRAM_DESCRIPTOR)
{
    mixin(q{alias VertexType = } ~ Type_to_dlang_type(PROGRAM_DESCRIPTOR.shaders[0].inputs[0].declaration.type) ~ q{;});
}

void Print_value(alias T)()
{
    import std.stdio;
    writeln(__traits(identifier, T), " = ", T);
}

void Increment_value(alias T)()
{
    T++;
}

unittest
{
    import std.stdio;
    writeln("TESTING GLSL MODULE");
    writeln(program_descriptor);

    int a = 12;
    Increment_value!a;
    Print_value!a;

    VertexType!program_descriptor vertex_type_instance = [0, 3, 4];
    Print_value!(vertex_type_instance);
}
