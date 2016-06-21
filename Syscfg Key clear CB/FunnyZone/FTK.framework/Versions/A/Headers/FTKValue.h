#ifndef FTK__Values__Value__hh__
#define FTK__Values__Value__hh__


#include <string>
#include <FTK/sptr.h>
#include <FTK/option.h>


class FTKAtom;
class FTKMap;
class FTKSet;
class FTKArray;

struct value_data: public ref_counted_t
{
	value_data(unsigned t)
	: type_check(type_type(t))
	{
	}

	virtual ~value_data() { }

	enum type_type {
		VALUE_ATOM,
		VALUE_MAP,
		VALUE_SET,
		VALUE_ARRAY,
	};

	type_type type_check;

	friend class sptr_t<value_data>;
};

class FTKValue
{
public:
	FTKValue();
	explicit FTKValue(char const *);
	explicit FTKValue(std::string const &);

	virtual ~FTKValue() { }

	virtual bool IsAtom()  const;
	virtual bool IsMap()   const;
	virtual bool IsSet()   const;
	virtual bool IsArray() const;

	virtual bool IsValid() const;

	virtual FTKAtom  AsAtom()  const;
	virtual FTKMap   AsMap()   const;
	virtual FTKSet   AsSet()   const;
	virtual FTKArray AsArray() const;

	/* shortcuts to avoid having to write .AsAtom().AsXXX() */
	int         AsInteger() const;
	double      AsFloat()   const;
	bool        AsBoolean() const;
	std::string const &AsString()  const;

	bool IsNumber()  const;
	bool IsInteger() const;
	bool IsFloat()   const;
	bool IsBoolean() const;

	/* useful for inspecting optional data */
	option<int>         AsIntegerOption() const;
	option<double>      AsFloatOption() const;
	option<bool>        AsBooleanOption() const;
	option<std::string> AsStringOption() const;


protected:
	sptr_t<value_data> m_impl;
};


FTKValue const operator / (FTKValue const &, std::string const &);
FTKValue const operator / (FTKValue const &, FTKAtom const &);
FTKValue const operator / (FTKValue const &, FTKValue const &);


std::string Serialize(FTKValue);


#endif



#include <FTK/FTKAtom.h>
#include <FTK/FTKMap.h>
#include <FTK/FTKSet.h>
#include <FTK/FTKArray.h>
