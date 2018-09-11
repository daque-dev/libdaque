module daque.graphics.image;

import daque.math.linear;

/++
	Represents an array of pixels
+/
class Image
{
public:
    /++
		Creates a new empty image with the specified width and height and optional fill

		params:
		width = width of the new image
		height = height of the new image
		fill = color to fill the new image
	+/
    this(uint width, uint height, uint fill = 0xffffffff)
    {
        m_width = width;
        m_height = height;

        m_pixel.length = m_width;
        for (uint i; i < m_width; i++)
        {
            m_pixel[i].length = m_height;

            for (uint j; j < m_height; j++)
            {
                m_pixel[i][j] = fill;
            }
        }
    }

    /++
		Gets a reference to the pixel located at position (x, y)

		params:
		x = x position of pixel from left to right
		y = y position of pixel from top to bottom
	+/
    ref uint opIndex(uint x, uint y)
    {
        return m_pixel[x][y];
    }

    /++
		Gets a linear representation of the image according to the matrixOrder rule
		that is, if matrixOrder is RowMajor, then the image is given row by row
		if matrixOrder is ColumnMajor, then the image is given column by column
	+/
    uint[] linearize(MatrixOrder matrixOrder)()
    {
        uint[] linearization;

        static if (matrixOrder == MatrixOrder.RowMajor)
        {
            for (uint y; y < m_height; y++)
            {
                for (uint x; x < m_width; x++)
                {
                    linearization ~= this[x, y];
                }
            }
        }
        static if (matrixOrder == MatrixOrder.ColumnMajor)
        {
            for (uint x; x < m_width; x++)
            {
                for (uint y; y < m_height; y++)
                {
                    linearization ~= this[x, y];
                }
            }
        }
        return linearization;
    }

private:
    uint[][] m_pixel;
    const uint m_width, m_height;
}
