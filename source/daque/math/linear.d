module daque.math.linear;

enum MatrixOrder
{
	RowMajor, ColumnMajor
}

struct Matrix(RealType, uint Rows, uint Columns, MatrixOrder Order = MatrixOrder.ColumnMajor)
{
	private RealType[Rows * Columns] m_element;
	
	ref RealType opIndex(uint i, uint j)
	{
		static if(Order == MatrixOrder.RowMajor)
		{
			return m_element[j * Rows + i];
		}
		else
		{
			return m_element[i * Columns + j];
		}
	}

	RealType[] linearize(MatrixOrder order = Order)()
	{
		RealType[] linearization;

		static if(order == Order)
		{
			linearization = m_element;
		}
		else
		{
			static if(order == MatrixOrder.RowMajor)
			{
				for(uint i; i < Rows; i++)
					for(uint j; j < Columns; j++)
						linearization ~= this[i, j];
			}
			else
			{
				for(uint j; j < Columns; j++)
					for(uint i; i < Rows; i++)
						linearization ~= this[i, j];
			}
		}

		return linearization;
	}

	static Matrix!(RealType, Rows, Columns, Order) Identity()
	{
		Matrix!(RealType, Rows, Columns, Order) identity;
		for(uint i; i < Rows; i++)
			for(uint j; j < Columns; j++)
				identity[i, j] = i == j;
		return identity;
	}

    RealType[Rows] column(uint j)
    {
        RealType[Rows] col;

        for(uint i; i < Rows; i++)
        {
            col[i] = this[i, j];
        }

        return col;
    }

    R[Rows] applyOn(RealType[] v)
    in
    {
        assert(v.length == Columns);
    }
    out
    {
        assert(w.length == Rows);
    }
    do
    {
        RealType[Rows] w;
        w[] = 0;

        for(uint e; e < Columns; e++)
            w[] += v[e] * this.column(e)[];

        return w;
    }
}



// unittest
// {
// 	import std.algorithm;
// 	import std.range;
// 	import std.stdio;
// 	auto identityColumn = Matrix!(real, 3, 3, MatrixOrder.ColumnMajor).Identity();
// 	auto identityRow = Matrix!(real, 3, 3, MatrixOrder.RowMajor).Identity();
// 	writeln(identityColumn.linearize!(MatrixOrder.RowMajor)());
// 	writeln(identityRow);
// }
