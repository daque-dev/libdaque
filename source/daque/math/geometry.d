/++
Authors: 
	Miguel Ángel (quevangel), quevangel@protonmail.com
	David Omar Flores Chávez (davidomarf), davidomarfch@gmail.com
+/
module daque.math.geometry;

import std.math;

/++
	Mathematical dot product
+/
R dot(R)(R[] v, R[] w)
in
{
	assert(v.length == w.length, 
		"Dot product can only be applied between to vectors of the same dimension");
	assert(v.length > 0,
		"Dot product can't be performed on empty vectors");
}
out
{

}
do
{
	import std.array;
	import std.algorithm;

	R[] products;
	products.length = v.length;
	products[] = v[] * w[];
	return products.array.sum;
}

///
unittest
{
	assert(dot([1, 0], [0, 1]) == 0);
	assert(dot([1, 0], [1, 0]) == 1);
	assert(dot([1, 2, 3], [1, 2, 3]) == 14);
}

/++
	Mathematical distance between to points
+/
real distance(R)(R[] v, R[] w)
in
{
	assert(v.length == w.length, "distance can only be calculated between same-dimensional vectors");
}
out
{
}
do
{
	R[] diff;
	diff.length = v.length;
	diff[] = w[] - v[];
	return magnitude(diff);
}

/++
	Mathematical cross product
+/
R[] cross(R)(R[] v, R[] w)
in
{
	assert(v.length == 3 && w.length == 3, "Cross product can only be applied between 3d vectors");
}
out (result)
{
	R[] resultDup = result.dup;
	assert(approxEqual(dot(resultDup, v), 0.0) && approxEqual(dot(resultDup, w), 0.0), "Cross product was not orthogonal to it's operands");
}
do
{
	R[] result;
	result.length = 3;
	for(uint i; i < 3; i++)
	{
		int j = (i + 1) % 3; 
		int k = (j + 1) % 3;
		result[i] = v[j] * w[k] - v[k] * w[j];
	}
	return result;
}

R magnitudeSquared(R)(R[] v)
out(result)
{
	assert(result >= 0);
}
do
{
	return dot(v, v);
}

real magnitude(R)(R[] v)
{
	return sqrt(cast(real)magnitudeSquared(v));
}

///
unittest{
	import daque.utils.test;
	
	Tester test = new Tester("Magnitude");

	test.approx!(magnitude!double)([0.0], 0.0);
	test.approx!(magnitude!double)([1.0, 1.0], sqrt(2.0));
	test.approx!(magnitude!double)([1.0, 3.0], 0.0);
}

R[] normalize(R)(R[] v)
in
{
	assert(magnitudeSquared(v) != 0, "Cannot normalize a zero vector");
}
out(result)
{
	assert(approxEqual(magnitudeSquared(result.dup), 1), "Normalized vector wasn't unitary");
}
do
{
	R[] normalized;
	normalized.length = v.length;
	normalized[] = v[] / magnitude(v);
	return normalized;
}
