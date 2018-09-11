module daque.graphics.attributeformat;

import std.conv;

import derelict.opengl;

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

    string toString()
    {
        string str = "AttributeFormat(index: "
            ~ to!string(index) ~
            ", size: " ~ to!string(size) ~ ")";
        return str;
    }
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
