#ifndef FTK__Values__Array__hh__
#define FTK__Values__Array__hh__


#include <FTK/FTKValue.h>


class FTKArray: public FTKValue
{
public:
	FTKArray();
	FTKValue const operator[] (int) const;

	size_t    NumItems() const;

	FTKArray &AddEntry(int, FTKValue const &);

	FTKArray &Append(FTKValue const &);
	FTKArray &AppendItemsOfArray(FTKArray const &);

private:
	FTKArray(sptr_t<value_data> const &v); /* for use by FTKValue */

	void copy_on_write();

	friend class FTKValue;
};


#endif
