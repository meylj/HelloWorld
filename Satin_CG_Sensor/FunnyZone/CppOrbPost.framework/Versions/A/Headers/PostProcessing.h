//
//  PostProcessing.h
//  clf2
//
//  Created by Aliel Kauchakje Pedrosa on 3/2/15.
//
//

#ifndef __clf2__PostProcessing__
#define __clf2__PostProcessing__

#include <stdio.h>

#include <map>
#include <string>

#include <VectorUtils/nDvectors2.h>
#include <FTK/FTKMap.h>
#include <FTK/FTKArray.h>

typedef std::vector<std::vector<float> > matrix;

struct probe_point {
    int x;
    int y;
};

struct global_parameters {
    bool touch_coords;
    std::string fixture_brand;
    size_t npy;
    size_t npx;
    size_t nframes;
    size_t nfx;
    size_t nfy;
    size_t nforces;
    FTKArray cumulus_d9;
    std::vector<float> forces;
};

std::map<std::string, nDvector<float> > orbchar_post(nDvector<float> raw, nDvector<float> baseline, nDvector<float> touchCoords, global_parameters constants);

std::map<std::string, nDvector<float> > orbcg_post(nDvector<float> forceData, nDvector<float> baseline, global_parameters constants);

void orbchar_post_coords(nDvector<float> touchCoords, FTKArray cumulus_d9, std::map<std::string, nDvector<float> >& r);

void orbchar_force_reconstruct(std::map<std::string, nDvector<float> > r, nDvector<float> k_inv, global_parameters constants);

/*!
 * Rounds the average spacing of a sorted list - here called optimal pitch.
 * @param list
 *  List to calculate optimal pitch
 * @return pitch
 *  Optimal pitch for the given list
 */
template <typename T>
int
optimal_pitch(std::vector<T> touch)
{
	std::vector<T> spacing = VectOp::diff(touch);
	
	int pitch =  (int)round(VectOp::Mean(spacing));
	
	return pitch;
}

#endif /* defined(__clf2__PostProcessing__) */
