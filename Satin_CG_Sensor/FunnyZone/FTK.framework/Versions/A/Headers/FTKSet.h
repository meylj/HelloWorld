#ifndef FTK__Values__Set__hh__
#define FTK__Values__Set__hh__


#include <FTK/FTKValue.h>


class FTKSet: public FTKValue
{
public:
	FTKSet();

	FTKSet &AddEntry(FTKAtom const &);
	FTKSet &AddEntry(std::string const &);

	FTKSet &DelEntry(FTKAtom const &);
	FTKSet &DelEntry(std::string const &);

	bool    Contains(FTKAtom const &) const;
	bool    Contains(std::string const &) const;

	FTKArray AsArray() const;

private:
	FTKSet(sptr_t<value_data> const &v); /* for use by FTKValue */

	void copy_on_write();

	friend class FTKValue;
};


#endif
