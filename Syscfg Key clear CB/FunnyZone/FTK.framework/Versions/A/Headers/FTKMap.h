#ifndef FTK__Values__Map__hh__
#define FTK__Values__Map__hh__


#include <FTK/FTKValue.h>
#include <FTK/FTKArray.h>


class FTKMap: public FTKValue
{
public:
	FTKMap();

	FTKValue const operator[] (char const *) const;
	FTKValue const operator[] (FTKAtom const &) const;
	FTKValue const operator[] (std::string const &) const;

	FTKMap &AddEntry(FTKAtom const &, FTKValue const &);
	FTKMap &AddEntry(std::string const &, FTKValue const &);
	FTKMap &AddEntry(char const *, FTKValue const &);
	FTKMap &AddEntriesFromMap(FTKMap);

	FTKMap &DelEntry(FTKAtom const &);
	FTKMap &DelEntry(std::string const &);

	bool HasKey(FTKAtom const &) const;
	bool HasKey(std::string const &) const;

	FTKArray GetKeys() const;

	FTKMap &operator = (FTKValue const &);

private:
	FTKMap(sptr_t<value_data> const &v); /* for use by FTKValue */

	void copy_on_write();

	friend class FTKValue;
};


#endif
