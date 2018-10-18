module daque.graphics.glsl;

import std.format;
import std.conv;
import std.algorithm.searching;
import std.range;
import std.string;

import daque.graphics.attributeformat;

import derelict.opengl;

/++
Glsl Module:
    - Purpose: 

Structs defined in this: 
    ScalarType:
        Can be one of the following:
            - Bool, Int, Uint, Float or Double

    VectorType:
        Is a vector of 2, 3 or 4 ScalarType's
        
    MatrixType:
        A Matrix of mxn floats

    GlslBasicType:
        Can be one of the following: 
            - ScalarType, VectorType or MatrixType

    GlslArrayOrGlslBasicType:
        Can be an array or not of GlslBasicType values

    Declaration;
    Uniform(Declaration declaration);
    LayoutInput;
    ProgramDescriptor;
    ShaderDescriptor;
    Program(ProgramDescriptor Program_Descriptor);
    VertexType(LayoutInput[] Layout_Inputs);
+/

struct ScalarType
{
    enum Type
    {
        Bool,
        Int,
        Uint, 
        Float,
        Double
    }
    Type type;

    string To_Dlang_String()
    {
        final switch(type)
        {
            case Type.Bool:
                return "bool";
            case Type.Int: 
                return "int";
            case Type.Uint: 
                return "uint";
            case Type.Float:
                return "float";
            case Type.Double: 
                return "double";
        }
    }

    GLenum Get_Gl_Type()
    {
        final switch(type)
        {
            case Type.Bool:
                assert(0, "UNSUPPORTED");
            case Type.Int: 
                return GL_INT;
            case Type.Uint: 
                return GL_UNSIGNED_INT;
            case Type.Float:
                return GL_FLOAT;
            case Type.Double: 
                return GL_DOUBLE;
        }  
    }

    static ScalarType From_String(string str, out bool success) 
    {
        ScalarType scalar_type;
        switch(str)
        {
            case "bool":
                scalar_type.type = Type.Bool;
                success = true;
                break;
            case "int":
                scalar_type.type = Type.Int;
                success = true;
                break;
            case "uint":
                scalar_type.type = Type.Uint;
                success = true;
                break;
            case "float":
                scalar_type.type = Type.Float;
                success = true;
                break;
            case "double":
                scalar_type.type = Type.Double;
                success = true;
                break;
            default: 
                success = false;
        }
        return scalar_type;
    }

    static ScalarType From_Char(char c, out bool success) 
    {
        ScalarType scalar_type;
        switch(c)
        {
            case 'b':
                scalar_type.type = Type.Bool;
                success = true;
                break;
            case 'i':
                scalar_type.type = Type.Int;
                success = true;
                break;
            case 'u':
                scalar_type.type = Type.Uint;
                success = true;
                break;
            case 'f':
                scalar_type.type = Type.Float;
                success = true;
                break;
            case 'd': 
                scalar_type.type = Type.Double;
                success = true;
                break;
            default:
                success = false;
        }
        return scalar_type;
    }

    char To_Char()
    {
        final switch(type)
        {
            case Type.Bool:
                return 'b';
            case Type.Int:
                return 'i';
            case Type.Uint:
                return 'u';
            case Type.Float:
                return 'f';
            case Type.Double:
                return 'd';
        }
    }

    /++
        Gets a "little string" representation of the scalar type represented by this.

        The little string representation depends on the type.
            LittleString(Bool) => 1b
            LittleString(Int) => 1i
            LittleString(Uint) => 1ui
            LittleString(Float) => 1f
            LittleString(Double) => 1d
    +/
    string Get_LittleString_Representation()
    {
        final switch(type)
        {
            case Type.Bool:
                return "1b";
            case Type.Int:
                return "1i";
            case Type.Uint: 
                return "1ui";
            case Type.Float: 
                return "1f";
            case Type.Double: 
                return "1d";
        }
    }

    string To_Glsl_String()
    {
        final switch(type)
        {
            case Type.Bool:
                return "bool";
            case Type.Int: 
                return "int";
            case Type.Uint: 
                return "uint";
            case Type.Float: 
                return "float"; 
            case Type.Double: 
                return "double";
        }
    }
}   

struct VectorType
{
    ScalarType scalar_type;
    uint components = 2;

    string To_Dlang_String()
    {
        return scalar_type.To_Dlang_String() ~ "[" ~ to!string(components) ~ "]";
    }

    string To_Glsl_String()
    {
        if(scalar_type.type == ScalarType.Type.Float)
        {
            return "vec" ~ to!string(components);
        }
        else
        {
            return scalar_type.To_Char() ~ "vec" ~ to!string(components);
        }
    }

    static VectorType From_String(string str, out bool success) 
    {
        success = true;

        char start_char = str[0];
        if (start_char != 'v')
            str = str[1 .. $];
        else
            start_char = 'f';

        VectorType vector_type;
        vector_type.scalar_type = ScalarType.From_Char(start_char, success);
        uint valid_reads;
        valid_reads = str.formattedRead!"vec%s"(vector_type.components);
        if(valid_reads != 1)
            success = false;

        return vector_type;
    }

    string Get_LittleString_Representation()
    {
        return to!string(components) ~ scalar_type.To_Char();
    }
}

struct MatrixType
{
    uint columns, rows;

    string To_Dlang_String()
    {
        return "Matrix!(float, " ~ to!string(rows) ~ ", " ~ to!string(columns) ~ ")";
    }

    string To_Glsl_String()
    {
        return "mat" ~ to!string(rows) ~ "x" ~ to!string(columns);
    }

    static MatrixType From_String(string str, out bool success) 
    {
        MatrixType matrix_type;

        if(str[0 .. 3] != "mat")
        {
            success = false;
            return matrix_type;
        }

        str = str[3 .. $];

        if(!(str.length == 3 || str.length == 1))
        {
            success = false;
            return matrix_type;
        }

        auto split = findSplit(str, "x");
        string first = split[0];
        string second = split[1];

        if(first.empty)
        {
            success = false;
            return matrix_type;
        }
        if (second.empty)
        {
            matrix_type.columns = matrix_type.rows = to!uint(first);
        }
        else
        {
            matrix_type.rows = to!uint(first);
            matrix_type.columns = to!uint(split[2]);
        }

        success = true;
        return matrix_type;
    }
}

struct GlslBasicType
{
    enum TypeSelection
    {
        Scalar, Vector, Matrix
    }
    TypeSelection selection;

    union Type
    {
        ScalarType scalar_type;
        VectorType vector_type;
        MatrixType matrix_type;
    }
    Type type;

    string To_Glsl_String()
    {
        final switch(selection)
        {
            case TypeSelection.Scalar: 
                return type.scalar_type.To_Glsl_String();
            case TypeSelection.Vector:
                return type.vector_type.To_Glsl_String();
            case TypeSelection.Matrix:
                return type.matrix_type.To_Glsl_String();
        }
    }

    string Get_LittleString_Representation()
    {
        final switch(selection)
        {
            case TypeSelection.Scalar: 
                return type.scalar_type.Get_LittleString_Representation();
            case TypeSelection.Vector:
                return type.vector_type.Get_LittleString_Representation();
            case TypeSelection.Matrix:
                assert(0, "MATRIX DOESN'T HAVE LITTLESTRING REPRESENTATION");
        }
    }

    uint Get_No_Components()
    {
        final switch(selection)
        {
            case TypeSelection.Scalar: 
                return 1;
            case TypeSelection.Vector: 
                return type.vector_type.components;
            case TypeSelection.Matrix:
                assert(0, "MATRIX DOESNT HAVE NO COMPONENTS");
        }
    }

    GLenum Get_Gl_Type()
    {
        final switch(selection)
        {
            case TypeSelection.Scalar: 
                return type.scalar_type.Get_Gl_Type();
            case TypeSelection.Vector: 
                return type.vector_type.scalar_type.Get_Gl_Type();
            case TypeSelection.Matrix:
                assert(0, "MATRIX DOESNT HAVE GL TYPE");
        }
    }

    string To_Dlang_String()
    {
        final switch(selection)
        {
            case TypeSelection.Scalar:
                return type.scalar_type.To_Dlang_String();
            case TypeSelection.Vector: 
                return type.vector_type.To_Dlang_String();
            case TypeSelection.Matrix:
                return type.matrix_type.To_Dlang_String();
        }
    }

    static GlslBasicType From_String(string str, out bool success)
    {
        GlslBasicType glsl_basic_type;
        bool read_success;
        {
            glsl_basic_type.selection = TypeSelection.Scalar;
            glsl_basic_type.type.scalar_type = ScalarType.From_String(str, read_success);
            if(read_success)
            {
                success = true;
                return glsl_basic_type;
            }
        }
        {
            glsl_basic_type.selection = TypeSelection.Vector;
            glsl_basic_type.type.vector_type = VectorType.From_String(str, read_success);
            if(read_success)
            {
                success = true;
                return glsl_basic_type;
            }
        }
        {
            glsl_basic_type.selection = TypeSelection.Matrix;
            glsl_basic_type.type.matrix_type = MatrixType.From_String(str, read_success);
            if(read_success)
            {
                success = true;
                return glsl_basic_type;
            }
        }

        success = false;
        return glsl_basic_type;
    }

    static GlslBasicType From_String_Safe(string str) 
    {
        bool success;
        GlslBasicType glsl_basic_type = From_String(str, success);
        assert(success);
        return glsl_basic_type;
    }
}

struct GlslArrayOrGlslBasicType 
{
    GlslBasicType glsl_basic_type;
    uint no_elements;
    bool is_array;

    string To_Dlang_String()
    {
        if (is_array)
        {
            return glsl_basic_type.To_Dlang_String() ~ "[" ~ to!string(no_elements) ~ "]";
        }
        else
        {
            return glsl_basic_type.To_Dlang_String();
        }
    }

    static GlslArrayOrGlslBasicType From_String(string str, out bool success) 
    {
        GlslArrayOrGlslBasicType array_or_glsl_basic_type;
        success = true;
        auto split = findSplitBefore(str, "[");
        string first = split[0];
        string second = split[1];

        if(!second.empty)
        {
            array_or_glsl_basic_type.glsl_basic_type = GlslBasicType.From_String(first, success);
            second.formattedRead!"[%s]"(array_or_glsl_basic_type.no_elements);
            array_or_glsl_basic_type.is_array = true;
            return array_or_glsl_basic_type;
        }
        else if(!first.empty)
        {
            array_or_glsl_basic_type.glsl_basic_type = GlslBasicType.From_String(first, success);
            array_or_glsl_basic_type.no_elements = 1;
            array_or_glsl_basic_type.is_array = false;
            return array_or_glsl_basic_type;
        }
        else
        {
            success = false;
            return array_or_glsl_basic_type;
        }
    }

    static GlslArrayOrGlslBasicType From_String_Safe(string str) 
    {
        bool success;
        GlslArrayOrGlslBasicType array_or_glsl_basic_type = From_String(str, success);
        assert(success);
        return array_or_glsl_basic_type;
    }
}

struct Declaration
{
    GlslArrayOrGlslBasicType type;
    string identifier;

    // EXPECTED BUG: IT WILL NOT WORK FOR ARRAYS
    static Declaration From_String(string str)
    {
        auto split = split(str, " ");
        Declaration declaration;
        assert(split.length == 2);
        declaration.type = GlslArrayOrGlslBasicType.From_String_Safe(split[0]);
        declaration.identifier = split[1];
        return declaration;
    }

    string To_Glsl_String()
    {
        if(type.is_array)
            return type.glsl_basic_type.To_Glsl_String() ~ " " ~ identifier ~ "[" ~ to!string(type.no_elements) ~ "]";
        else
            return type.glsl_basic_type.To_Glsl_String() ~ " " ~ identifier;
    }

    string To_Dlang_String()
    {
        return type.To_Dlang_String() ~ " " ~ identifier;
    }
}

struct Uniform(Declaration declaration)
{
    mixin("alias Type = " ~ declaration.type.To_Dlang_String() ~ ";");
    int location;
    int program;

    void Set_Program(int program)
    {
        this.program = program;
        this.location = glGetUniformLocation(program, toStringz(declaration.identifier));
    }

    void Set(Type value)
    {
        static if (declaration.type.glsl_basic_type.selection == GlslBasicType.TypeSelection.Scalar && !declaration.type.is_array)
        {
            enum string Type_Little_String = declaration.type.glsl_basic_type.Get_LittleString_Representation();
            mixin("alias ProgramUniform = glProgramUniform" ~ Type_Little_String ~ "v;");
            ProgramUniform(program, location, 1, &value);
        }
        else static if (declaration.type.glsl_basic_type.selection == GlslBasicType.TypeSelection.Matrix)
        {
            // TODO: Support Matrix Uniform setting
            static assert(0, "MATRIX UNIFORM NOT SUPPORTED");
        }
        else 
        {
            enum string Type_Little_String = declaration.type.glsl_basic_type.Get_LittleString_Representation();
            mixin("alias ProgramUniform = glProgramUniform" ~ Type_Little_String ~ "v;");
            ProgramUniform(program, location, declaration.type.no_elements, value.ptr);
        }
    }

    void opAssign(Type value)
    {
        this.Set(value);
    }
}

struct LayoutInput
{
    int location = -1;
    Declaration declaration;
    enum Normalized : bool
    {
        NORMALIZE = true, DONT_NORMALIZE = false
    }
    Normalized normalized;

    string To_Glsl_String()
    {
        assert(location >= 0);
        return "layout (location = " ~ to!string(location) ~ ") in " ~ declaration.To_Glsl_String();
    }
}

struct ProgramDescriptor
{
    ShaderDescriptor vertex_shader;
    ShaderDescriptor fragment_shader; 
}

struct ShaderDescriptor
{
    string glsl_version;
    LayoutInput[] layout_inputs;
    Declaration[] inputs;
    Declaration[] uniforms;
    Declaration[] outputs;
    string source;

    string Get_Full_Source()
    {
        string full_source; 

        full_source ~= glsl_version;
        full_source ~= '\n';

        foreach(LayoutInput layout_input; layout_inputs)
        {
            full_source ~= layout_input.To_Glsl_String() ~ ";";
            full_source ~= '\n';
        }

        foreach(Declaration input; inputs)
        {
            full_source ~= "in " ~ input.To_Glsl_String() ~ ";";
            full_source ~= '\n';
        }

        foreach(Declaration uniform; uniforms)
        {
            full_source ~= "uniform " ~ uniform.To_Glsl_String() ~ ";";
            full_source ~= '\n';
        }

        foreach(Declaration output; outputs)
        {
            full_source ~= "out " ~ output.To_Glsl_String() ~ ";";
            full_source ~= '\n';
        }

        full_source ~= source;

        return full_source;
    }
}

import daque.graphics.opengl;

struct Program(ProgramDescriptor PROGRAM_DESCRIPTOR)
{
    int vertex_shader, fragment_shader;
    int program_id;

    alias Vertex = VertexType!(PROGRAM_DESCRIPTOR.vertex_shader.layout_inputs);

    static foreach(Declaration UNIFORM_DECLARATION; PROGRAM_DESCRIPTOR.vertex_shader.uniforms)
    {
        mixin(q{Uniform!(UNIFORM_DECLARATION) } ~ UNIFORM_DECLARATION.identifier ~ ";");
    }

    void init()
    {
        program_id = glCreateProgram();

        vertex_shader = Compile_Shader(GL_VERTEX_SHADER, 
                PROGRAM_DESCRIPTOR.vertex_shader.Get_Full_Source());

        fragment_shader = Compile_Shader(GL_FRAGMENT_SHADER, 
                PROGRAM_DESCRIPTOR.fragment_shader.Get_Full_Source());

        Attach_Shaders(program_id, [vertex_shader, fragment_shader]);

        Link_Program(program_id);
    }
    

}

enum ProgramDescriptor TESTING_PROGRAM_DESCRIPTOR = 
{
    vertex_shader: {
        glsl_version: "#version 330 core",
        layout_inputs: [
            {0, Declaration.From_String("vec3 position"), normalized: LayoutInput.Normalized.DONT_NORMALIZE}, 
            {1, Declaration.From_String("vec4 color"), normalized: LayoutInput.Normalized.NORMALIZE}
        ], 
        uniforms: [
            Declaration.From_String("float z_near"),
            Declaration.From_String("float z_far"),
            Declaration.From_String("float alpha"),
            Declaration.From_String("float xy_ratio"),
            Declaration.From_String("vec3 translation")
        ],
        outputs: [
            Declaration.From_String("vec4 v_color")
        ],
        source: q{
            void main()
            {
                vec3 rotated = position;
                vec3 translated = rotated + translation;
                gl_Position = vec4(position, 1);
            }
        }
    },
    fragment_shader: {
        glsl_version: "#version 330 core",
        outputs: [
            Declaration.From_String("vec4 final_color")
        ],
        inputs: [
            Declaration.From_String("vec4 v_color")
        ], 
        source: q{
            void main()
            {
                final_color = v_color;
            }
        }
    }
};

template VertexType(LayoutInput[] LAYOUT_INPUTS)
{
    struct VertexType
    {
        static foreach(LayoutInput LAYOUT_INPUT; LAYOUT_INPUTS)
        {
            mixin(LAYOUT_INPUT.declaration.To_Dlang_String() ~ ";");
        }

        static AttributeFormat[] INPUT_FORMATS;

        static this()
        {
            static foreach(LayoutInput LAYOUT_INPUT; LAYOUT_INPUTS)
            {
                mixin(
                r"
                {
                    AttributeFormat format = {
                        index: LAYOUT_INPUT.location,
                        size: LAYOUT_INPUT.declaration.type.glsl_basic_type.Get_No_Components(), 
                        type: LAYOUT_INPUT.declaration.type.glsl_basic_type.Get_Gl_Type(),
                        normalized: LAYOUT_INPUT.normalized? GL_TRUE: GL_FALSE,
                        stride: this.sizeof,
                        pointer: cast(void*) this." ~ LAYOUT_INPUT.declaration.identifier ~ r".offsetof
                    };
                   INPUT_FORMATS ~= format;
                }
                ");
            }
        }
    }
}

void Print_Value(alias T)()
{
    import std.stdio;
    writeln(__traits(identifier, T), " = ", T);
}

unittest
{
    import daque.graphics.sdl;
    import derelict.sdl2.sdl;
    import std.stdio;

    Window window = new Window("something", 800, 600);
    Program!TESTING_PROGRAM_DESCRIPTOR testing_program;
    testing_program.init;
    testing_program.z_near = 0.13f;
    window.close;

    testing_program.Vertex v;
    v.position[] = [2, 3, 4];
    v.color[] = [123, 21, 31, 3];
}

