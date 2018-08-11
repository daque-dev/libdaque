module daque.math.quaternion;

import std.math;

import daque.math.geometry;

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

	public real abs()
	{
		return sqrt(squareAbs);
	}

	public real squareAbs()
	{
		return (this * this.conjugate).scalar;
	}
}
