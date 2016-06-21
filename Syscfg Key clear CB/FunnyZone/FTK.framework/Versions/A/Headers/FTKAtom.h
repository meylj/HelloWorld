#ifndef FTK__Values__Atom__hh__
#define FTK__Values__Atom__hh__


#include <FTK/FTKValue.h>


class FTKAtom: public FTKValue
{
public:
	FTKAtom() {};
	explicit FTKAtom(int);
	explicit FTKAtom(bool);
	explicit FTKAtom(double);
	explicit FTKAtom(char const *);
	explicit FTKAtom(std::string const &);

	bool IsNumber()  const;
	bool IsInteger() const;
	bool IsFloat()   const;
	bool IsBoolean() const;

	int         AsInteger() const;
	double      AsFloat()   const;
	bool        AsBoolean() const;
	std::string const &AsString()  const;

	option<int>         AsIntegerOption() const;
	option<double>      AsFloatOption() const;
	option<bool>        AsBooleanOption() const;
	option<std::string> AsStringOption() const;

private:
	FTKAtom(sptr_t<value_data> const &v); /* for use by FTKValue */

	friend class FTKValue;
};


#endif
