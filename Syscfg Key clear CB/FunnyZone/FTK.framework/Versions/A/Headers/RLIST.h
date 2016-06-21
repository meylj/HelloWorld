/*
 *  RLIST.h
 *  CrimsonAcoustics
 *
 *  Created by Manuel Petit on 2/24/09.
 *  Copyright 2009 Apple Inc. All rights reserved.
 *
 */

#ifndef TK_factory__tk_rlist__rlist__hh__
#define TK_factory__tk_rlist__rlist__hh__


#include <string>
#include <FTK/sptr.h>
#include <FTK/FTKMap.h>

class RList_t
{
public:
	RList_t(std::string const &str);
	RList_t(void const *buffer, size_t len);

	std::string   GetErrors() const;
	FTKMap        GetRootNode() const;

	static RList_t LoadFile(std::string const &fname);

private:
	std::string   m_errors;
	FTKMap        m_data;
};


#endif
