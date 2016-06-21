//
//  Interpolation.h
//  clf2
//
//  Created by Aliel Kauchakje Pedrosa on 3/5/15.
//
//

#ifndef __clf2__Interpolation__
#define __clf2__Interpolation__

#include <stdio.h>
#include <vector>
#include <VectorUtils/nDvectors2.h>

typedef std::vector<std::vector<float> > matrix;

// !!!: add header doc
matrix					interpv4(nDvector<float> x, nDvector<float> y, nDvector<float> v, nDvector<float> xq, nDvector<float> yq);

// !!!: add header doc
std::vector<float>		interpv4(std::vector<float> x, std::vector<float> y, std::vector<float> v, std::vector<float> xq, std::vector<float> yq);

// !!!: add header doc
matrix					interp2LinearExtrap(matrix xx, matrix yy, matrix v, matrix xq, matrix yq);

// !!!: add header doc
matrix					interp2LinearExtrap(nDvector<float> xx, nDvector<float> yy, nDvector<float> v, nDvector<float> xq, nDvector<float> yq);

// !!!: add header doc
matrix					interp2LinearExtrap(nDvector<float> xx, nDvector<float> yy, matrix v, nDvector<float> xq, nDvector<float> yq);

#endif /* defined(__clf2__Interpolation__) */
