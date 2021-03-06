module daque.math.quaternion;

import std.math;

import daque.math.geometry;
import daque.math.linear;

struct Quaternion(R)
{
	public R scalar;
	public R[3] vector;

	public this(R[4] components)
	{
		scalar = components[0];
		vector[] = components[1 .. 4];
	}

	public this(R scalar, R[3] vector)
	{
		this.scalar = scalar;
		this.vector = vector;
	}

	static public Quaternion!R getRotation(R[3] axis, R amount)
	{
		Quaternion quaternion = Quaternion([0, 0, 0, 0]);
		quaternion.scalar = sin(amount / 2.0f);
		quaternion.vector[] = cos(amount / 2.0f) * axis[];
		return quaternion;
	}

	Matrix!(R, 3, 3) getRotationMatrix()
	{
		auto m = Matrix!(R, 3, 3).Identity();

		for(uint j; j < 3; j++)
		{
			Quaternion columnQuaternion = Quaternion([0, 0, 0, 0]);
			columnQuaternion.scalar = 0;
			for(uint i; i < 3; i++)
				columnQuaternion.vector[i] = m[i, j];

			columnQuaternion = columnQuaternion * this;
			for(uint i; i < 3; i++)
				m[i, j] = columnQuaternion.vector[i];
		}

		return m;
	}

	public Quaternion opBinary(string op)(Quaternion rhs)
	{
		Quaternion result;
		static if (op == "+")
		{
			result.scalar = this.scalar + rhs.scalar;
			result.vector[] = this.vector[] + rhs.vector[];
		}
		else static if (op == "*")
		{
			result.scalar = this.scalar * rhs.scalar - dot(this.vector, rhs.vector);
			result.vector[] = this.scalar * rhs.vector[] + this.vector[] * rhs.scalar + cross(this.vector, rhs.vector)[];
		}
		else 
		{
			static assert(0, "Quaternion: Unsupported operation: " ~ op);
		}
		return result;
	}

	public Quaternion conjugate()
	{
		Quaternion conjugateQuaternion;
		conjugateQuaternion.scalar = this.scalar; 
		conjugateQuaternion.vector[] = -1 * this.vector[]; 
		return conjugateQuaternion;
	}

	public Quaternion inverse()
	{
		Quaternion invSquareAbs = Quaternion(1.0 / squareAbs(), [0, 0, 0]);
		return conjugate() * invSquareAbs;
	}

	public real abs()
	{
		return sqrt(squareAbs);
	}

	public real squareAbs()
	{
		return (this * this.conjugate).scalar;
	}
}
