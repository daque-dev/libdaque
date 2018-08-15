/++
Authors: Miguel Ángel (quevangel), quevangel@protonmail.com
+/

module daque.graphics.opengl;

import std.string;
import std.file;
import std.algorithm;

import core.stdc.stdlib;

import derelict.opengl;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

import daque.math.geometry;

/// Renders an Array of vertices already on GPU memory
void render(GpuArray vertices)
{
	vertices.bind();
	glDrawArrays(GL_TRIANGLES, 0, cast(int) vertices.size());
}

/++
Initializes required libraries for graphics rendering.

Initializes SDL2 and OpenGL libraries.
	+/
static this()
{
	DerelictGL3.load();
}

/++
	+/
static ~this()
{
}
/++
Represents a 'shader' OpenGL object.

A shader is *part* of a program ought to be executed by the GPU.
This class serves as a way to compile and use those program parts.

The "whole" Program is another OpenGL object constructed by assembling
many Shader s.
+/
class Shader
{
public:
	/// Types of shaders there can be
	enum Type
	{
		Vertex,
		Fragment
	}
	/++
			Get the type of the shader
			Returns: type of the shader
			+/
	@property Type type()
	{
		return m_type;
	}

	/++
			Constructs a new shader of the specified type, using as source code the file pointed to by
			sourcePath

			Params:
			type = Type of the shader to be constructed
			sourcePath = String representing a path to a file containing the 
			source code which will be used as source for the constructed shader
			+/
	this(Shader.Type type, string sourcePath)
	{
		m_type = type;
		m_shaderGlName = cast(immutable(GLuint)) compileShader(type, sourcePath);
	}

	~this()
	{
		glDeleteShader(m_shaderGlName);
	}

private:
	immutable(GLuint) m_shaderGlName;
	immutable(Type) m_type;
	/++
			Compiles a shader of the specified type, using as source code the file pointed to by sourcePath 
			and returns the name of the opengl object representing the compiled shader.

			Params:
			type = Type of shader to be compiled
			sourcePath = Path to the shader's source code

			Returns:
			Opengl Name of the compiled shader
			+/
	static GLuint compileShader(immutable Type type, string sourcePath)
	{
		// Create and compile
		GLuint shaderName = glCreateShader(typeToGlenum(type));
		const char* sourceCodeZ = toStringz(readText(sourcePath));
		glShaderSource(shaderName, 1, &sourceCodeZ, null);
		glCompileShader(shaderName);

		// Error checking
		GLint compilationSuccess = 0;
		glGetShaderiv(shaderName, GL_COMPILE_STATUS, &compilationSuccess);
		// Error case
		if (compilationSuccess == GL_FALSE)
		{
			GLint logSize = 0;
			GLchar[] errorLog;

			glGetShaderiv(shaderName, GL_INFO_LOG_LENGTH, &logSize);
			errorLog.length = logSize;
			glGetShaderInfoLog(shaderName, logSize, &logSize, &errorLog[0]);
			string info = cast(string) fromStringz(&errorLog[0]);

			import std.stdio : writeln;
			writeln("COMPILATION ERROR: ", info);

			glDeleteShader(shaderName);
			shaderName = 0;
		}
		else // Success case
		{
		}

		return shaderName;
	}

	/++
			Maps Shader.Type to equivalent OpenGL GLenum.

			Params:
			type = type to be mapped to GLenum
			Returns: 
			GLenum equivalent of type
			+/
	static pure GLenum typeToGlenum(Shader.Type type)
	{
		final switch (type)
		{
		case Shader.Type.Vertex:
			return GL_VERTEX_SHADER;
		case Shader.Type.Fragment:
			return GL_FRAGMENT_SHADER;
		}
	}
}

/++
Represents and handles a Program Opengl Object.
A Program is a group of Opengl Shaders which will be linked together.
A Program is  a program to be executed by the GPU to each of the Vertices of a model.
+/
class Program
{
public:
	/++
			Creates a new empty program
			+/
	this()
	{
		m_programGlName = glCreateProgram();
	}
	/++ 
			Creates a program with the specified shaders already attached
			+/
	this(Shader[] shaders)
	{
		this();
		shaders.each!(s => this.attach(s));
	}

	~this()
	{
		glDeleteProgram(m_programGlName);
	}
	/++
			Attaches the shader to this program

			Params:
			shader = Shader to be attached
			+/
	void attach(Shader shader)
	{
		glAttachShader(m_programGlName, shader.m_shaderGlName);
	}
	/++
			Links the currently attached shaders
			+/
	void link()
	{
		glLinkProgram(m_programGlName);

		GLint isLinked = 0;
		glGetProgramiv(m_programGlName, GL_LINK_STATUS, cast(int*)&isLinked);
		if (isLinked == GL_FALSE)
		{
			import std.stdio: writeln;
			writeln("LINKING ERROR");
		}
	}

	/++
			Binds the program to the current opengl context so that it is used to process new render
			commands
			+/
	void use()
	{
		glUseProgram(m_programGlName);
	}


	int getUniformLocation(string name)
	{
		return glGetUniformLocation(m_programGlName, name.toStringz());
	}

	template strToType(string typeString)
	{
		static if(typeString == "i")
			alias strToType = int;
		else static if(typeString == "f")
			alias strToType = float;
		else
			static assert(0, "unrecognized string type " ~ typeString);
	}

	import std.conv;
	/++
			Sets a integer uniform variable inside the program

			Params:
			uniformName = name of the single-valued uniform integer to be changed
			val = new value to be assigned
			+/
	void setUniform(uint count, string typeString)(int location, void[] data)
	{
		this.use();
		mixin("alias glUniform = " ~ "glUniform" ~ to!string(count) ~ typeString ~ "v;");
		glUniform(location, cast(int)(data.length / (strToType!typeString.sizeof * count)), cast(strToType!typeString*)data.ptr);
	}

	// TODO: setUniformMatrix method

	void getUniform(string typeString)(int location, strToType!typeString* output)
	{
		mixin("alias glGetUniform = glGetUniform" ~ typeString ~ "v;");
		glGetUniform(m_programGlName, location, output);
	}

private:
	// associated Opengl Object Program's name
	immutable(GLuint) m_programGlName;

}

/++
Represents a buffer opengl object.
A buffer opengl object is the mechanism through which data can be stored in the GPU, usually
vertex data of the models to be rendered.

This class eases/abstracts the interaction with this kind of opengl objects.
+/
class Buffer
{
public:
	/++
			Constructs a new and empty buffer
			+/
	this()
	{
		m_name = Buffer.gen();
	}

	~this()
	{
		del(m_name);
	}

	/++
			Generates a new opengl buffer and returns it's name
			Returns: name of the newly created opengl buffer
			+/
	static GLuint gen()
	{
		GLuint buffer;
		glGenBuffers(1, &buffer);
		return buffer;
	}

	/++ 
			Deletes a opengl buffer given it's name
			Params :
			buffer = opengl name of the opengl buffer
			+/
	static void del(GLuint buffer)
	{
		glDeleteBuffers(1, &buffer);
	}

	/++
			Sends the unformatted data of the specified size to the buffer

			Params:
			data = Pointer to the data to be sent
			size = Size in bytes of the data to be sent
			+/
	void bufferData(void* data, size_t size)
	{
		bind();
		glBufferData(GL_ARRAY_BUFFER, size, data, GL_DYNAMIC_DRAW);
	}

	/++
			Binds the buffer to the current opengl context
			+/
	void bind()
	{
		glBindBuffer(GL_ARRAY_BUFFER, m_name);
	}

private:
	// opengl name of the buffer managed by @this
	immutable(GLuint) m_name;
}

/++
Data needed to represent a particular attribute for a Vertex.
+/
struct AttributeFormat
{
	/// OpenGL identifies each attribute by an @index
	GLuint index;
	/// No. of components of this attribute
	GLint size;
	/// Data type of the components of this attribute
	GLenum type;
	/// Does it need to be _normalized_(Clipped to a range of 0.0 - 1.0)?
	GLboolean normalized;
	/// Space between each appearance of this attribute in an array of Vertices, equivalently, the
	/// size of each Vertex
	GLsizei stride;
	/// Offset to first appearance of this attribute in an array of Vertices, equivalently, the
	/// offset of this member in the Vertex structure
	const GLvoid* pointer;
}

/++
Given the Buffer and the VertexArray currently bound to the OpenGL context, this function provides
format info about the attribute format.index of the vertices in the VertexArray.

This associates the Buffer to the VertexArray.

Params:
format = attribute format to be given to the VertexArray currently bound
	+/
void setup(AttributeFormat format)
{
	glEnableVertexAttribArray(format.index);

	glVertexAttribPointer(format.index, format.size, format.type,
			format.normalized, format.stride, format.pointer);
}

/++
Represents an opengl Vertex Array Object (VAO).
A VAO relates Opengl Buffers and Vertex Formats.
+/
class VertexArray
{
private:
	// opengl name of the VAO managed by @this
	immutable(GLuint) m_name;
public:
	/++
			Generates and empty VAO and saves it's name
			+/
	this()
	{
		m_name = genVertexArray();
	}

	static GLuint genVertexArray()
	{
		GLuint name;
		glGenVertexArrays(1, &name);
		return name;
	}
	/++
			Deallocates the VAO
			+/
	~this()
	{
		deleteVertexArray(m_name);
	}

	static void deleteVertexArray(GLuint vertexArrayName)
	{
		glDeleteVertexArrays(1, &vertexArrayName);
	}
	/++
			Associates this VertexArray with the buffer and the format given by the type
			VertexType.

			Inputs:
			buffer = Buffer to associae with this VertexArray and this format
			+/
	void use(Buffer buffer, AttributeFormat[] formats)
	{
		bind();
		buffer.bind();
		formats.each!setup;
	}

	/++
			Binds this VertexArray to the opengl context
			+/
	void bind()
	{
		glBindVertexArray(m_name);
	}
}

/++
Represents an array of things to be stored in the GPU
Params:
DataType = Type of the data to be stored
	+/
class GpuArray
{
private:
	Buffer m_buffer;
	VertexArray m_vao;
	uint m_size;

public:
	/++
			Creates and fills a new gpu array

			Params:
			data = data to be initialy filled with
			+/
	this(void[] data, uint noElements, AttributeFormat[] attributeFormats)
	{
		m_buffer = new Buffer();
		m_vao = new VertexArray();
		m_size = noElements;

		m_buffer.bufferData(data.ptr, data.length);
		m_vao.use(m_buffer, attributeFormats);
	}

	/// Binds the associated VertexArray to the opengl context
	void bind()
	{
		m_vao.bind();
	}

	uint size()
	{
		return m_size;
	}
}

/++
Represents a 2D opengl texture
+/
class Texture
{
private:
	immutable(GLuint) m_name;
	immutable(GLenum) m_type;

	immutable(SDL_Surface*) m_surface;
	immutable(uint) m_width, m_height;

public:
	/++
			Constructs a Texture from an image file got from imagePath

			Params:
			imagePath = path to the image to be used as a source to construct the texture
			+/
	this(string imagePath)
	{
		m_type = GL_TEXTURE_2D;
		m_surface = cast(immutable(SDL_Surface*)) IMG_Load(imagePath.toStringz());
		m_width = m_surface.w;
		m_height = m_surface.h;

		if (!m_surface) // error reading surface
		{
			return;
		}
		else if (m_surface.format.format != SDL_PIXELFORMAT_RGBA32) // unsupported pixel format
		{
			return;
		}

		m_name = Texture.gen();
		this.bind();
		this.setParameter!"i"(GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		this.setParameter!"i"(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_surface.w, m_surface.h, 0,
				GL_RGBA, GL_UNSIGNED_BYTE, m_surface.pixels);
	}

	/++
			Constructs an empty Texture with the specified width and height, and fills it with color
			clearColor

			Params:
			width = width of the texture to be constructed
			height = height of the texture to be constructed
			clearColor = color to be filled with
			+/
	this(uint width, uint height, uint clearColor = 0xffffffff)
	{
		m_width = width;
		m_height = height;

		m_name = Texture.gen();
		m_type = GL_TEXTURE_2D;
		m_surface = null;

		this.bind();
		this.setParameter!"i"(GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		this.setParameter!"i"(GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexImage2D(m_type, 0, GL_RGBA, m_width, m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, null);
	}

	~this()
	{
		Texture.del(m_name);
	}

	/++
			Fills the texture with color clearColor
			+/
	void clear(uint clearColor)
	{
		//t glClearTexImage(m_name, 0, GL_RGBA, GL_UNSIGNED_BYTE, &clearColor);
	}

	private template GLType(string name)
	{
		static if (name == "f")
		{
			alias GLType = GLfloat;
		}
		else static if (name == "i")
		{
			alias GLType = GLint;
		}
	}
	/// Sets an internal opengl parameter for the texture
	void setParameter(string typename)(GLenum parameterName, GLType!typename value)
	{
		this.bind();

		mixin("alias glTexParameter = glTexParameter" ~ typename ~ ";");
		glTexParameter(m_type, parameterName, value);
	}

	/// Returns the width of the texture
	uint width()
	{
		return m_width;
	}
	/// Returns the height of the texture
	uint height()
	{
		return m_height;
	}

	/// Binds the texture to the opengl context
	void bind()
	{
		glBindTexture(m_type, m_name);
	}

	/// Returns the opengl index of the texture ( aka: it's name )
	GLuint name()
	{
		return m_name;
	}
	/++
			Sets the pixels of a specified rectangular region

			Params:
			offsetx = x coordinate ( from low left texture corner ) of the low left corner of
			the region

			offsety = y coordinate ( from low left texture corner ) of the low left corner of
			the region

			width = width of the region
			height = height of the region

			data = data in row major order of the pixels to be set
			+/
	void updateRegion(uint offsetx, uint offsety, uint width, uint height, uint[] data)
	in
	{
		assert(data.length >= width * height);
	}
	out
	{
	}
	do
	{
		this.bind();
		glTexSubImage2D(m_type, 0, offsetx, offsety, width, height, GL_RGBA,
				GL_UNSIGNED_BYTE, data.ptr);
	}

	/++
			Generates a new opengl texture and returns it's name

			Returns: the name of the newly created texture
		+/
	static GLuint gen()
	{
		GLuint name;
		glGenTextures(1, &name);
		return name;
	}

	/++
			Deletes an opengl texture using it's name
			+/
	static void del(GLuint texture)
	{
		glDeleteTextures(1, &texture);
	}
}

/++
Assigns texture to textureUnit.

Params:
textureUnit = texture unit index to be set
texture = texture to be assigned
	+/
void setTextureUnit(int textureUnit, Texture texture)
{
	glActiveTexture(GL_TEXTURE0 + textureUnit);
	glBindTexture(texture.m_type, texture.m_name);
}
