#ifndef FTK__Values__Value_Utils__hh__
#define FTK__Values__Value_Utils__hh__


#include <vector>
#include <FTK/FTKValue.h>


namespace FTK
{
	template <typename T>
	std::vector<T> CxxVectorFromValue(FTKValue);

	bool CxxVectorFromValue(FTKValue, std::vector<bool> &);
	bool CxxVectorFromValue(FTKValue, std::vector<int> &);
	bool CxxVectorFromValue(FTKValue, std::vector<unsigned> &);
	bool CxxVectorFromValue(FTKValue, std::vector<float> &);
	bool CxxVectorFromValue(FTKValue, std::vector<double> &);
	bool CxxVectorFromValue(FTKValue, std::vector<std::string> &);

	/*
	 * Just for calculating integrity checks/hashs
	 */
	std::string SyndromeForFTKValue(FTKValue value, FTKValue params);

#if 0
	/*
     * Bridges to Objective-C
     */
	id            AsNSObject(FTKValue const &);
	NSString     *AsNSString(FTKAtom const &);
	NSArray      *AsNSArray(FTKArray const &);
	NSArray      *AsNSArray(FTKSet const &);
	NSDictionary *AsNSDictionary(FTKMap const &);
#endif
}


#endif
