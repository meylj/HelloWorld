/*
 * Copyright 2009, Apple Inc.
 */
#ifndef crimson__frameworks__ftk__option__hh__
#define crimson__frameworks__ftk__option__hh__


/* An SML-like option type */
template <typename T>
struct option
{
	option()
	: some(false)
	{
	}

	option(T const &t)
	: some(true)
	, val(t)
	{
	}

	template <typename U>
	option(option<U> const &o)
	: some(o.some)
	, val(o.val)
	{
	}

	option & operator = (option const &o)
	{
		some = o.some;
		val  = o.val;

		return *this;
	}

	template <typename U>
	option & operator = (option<U> const &o)
	{
		some = o.some;
		val  = o.val;
	}

	/*
	 * SML like constructors
	 */
	static option<T> Some(T const &t)
	{
		option<T> rv;

		rv.some = true;
		rv.val  = t;

		return rv;
	}
	static option<T> None()
	{
		option<T> rv;

		rv.some = false;

		return rv;
	}

	/*
	 * Inspectors
	 */
	bool IsSome() const
	{
		return some;
	}
	bool IsNone() const
	{
		return !some;
	}

	operator T       &()
	{
		if (IsNone()) throw("FTK::Option::ValOf(None)");

		return val;
	}
	operator T const &() const
	{
		if (IsNone()) throw("FTK::Option::ValOf(None)");

		return val;
	}

	bool some;
	T    val;
};


#endif
