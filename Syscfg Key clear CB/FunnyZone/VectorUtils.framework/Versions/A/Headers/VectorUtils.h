//
//  VectorUtils.h
//  VectorUtils
//
//  Created by Aliel Kauchakje Pedrosa on 3/1/15.
//  Copyright (c) 2015 Aliel Kauchakje Pedrosa. All rights reserved.
//

#ifndef __AudioTools__VectorUtils__
#define __AudioTools__VectorUtils__

#include <iostream>
#include <vector>
#include <complex>
#include <numeric>
#include <cmath>
#include <algorithm>
#include <FTK/FTKArray.h>
#include <FTK/FTKMap.h>
#include <FTK/FTKValueUtils.h>

#define Sum Add
typedef std::complex<double> complex;

template <typename T>
struct AbsComparator : public std::binary_function<T,T,bool>
{
	bool operator()(T o1, T o2)
	{
		return (std::abs(o1) < std::abs(o2));
	}
};


namespace VectOp
{
	/*******************************
	 ***** MATLAB-like Functions ****
	 ********************************/
	
	/*!
	 * Generate a vector within the closed interval ['init', 'end'] with step 'step'
	 * @param init Initial value
	 * @param end Final value
	 * @param step Step to go from 'init' to 'end'
	 * @return range_vec Vector of evenly spaced values
	 */
	template<typename T>
	std::vector<T>
	Range(T init, T end, T step)
	{
		std::vector<T> range_vec;
		while (init <= end) {
			range_vec.push_back(init);
			init += step;
		}
		return range_vec;
	}
	
	/*!
	 * Generate a linearly spaced vector between 'a' and 'b'
	 * @param a Initial value
	 * @param b Final value
	 * @param N Number of points
	 * @return range_vec Vector of N evenly spaced values
	 */
	template<typename T>
	std::vector<T>
	linspace(T a, T b, int N)
	{
		T h = (b - a) / (N-1);
		std::vector<T> xs(N);
		typename std::vector<T>::iterator x;
		T val;
		for (x = xs.begin(), val = a; x != xs.end(); ++x, val += h) {
			*x = val;
		}
		return xs;
	}
	
	/*!
	 * Generate a logarithmically spaced vector between base^a and base^b
	 * @param a Initial exponent
	 * @param b Final exponent
	 * @param N Number of points
	 * @param base Base of the log space. Default = 10
	 * @return range_vec Vector of N logarithmically spaced values
	 */
	template<typename T>
	std::vector<T>
	logspace(T a, T b, int N, T base = 10)
	{
		std::vector<T> array(N);
		array = linspace(a,b,N);
		for (int i = 0; i < array.size(); i++) {
			array[i] = pow(base,array[i]);
		}
		return array;
	}
	
	/*******************************
	 ***** Vector-to-Scalar Sum *****
	 ********************************/
	/*!
	 * double precision sum between a scalar and a vector: vec_out = vec_in + factor
	 * @param vec_in Input vector
	 * @param factor Value to be added to 'vec_in'
	 * @return sum of vec_in and factor
	 */
	std::vector<double> Add(std::vector<double> const &vec_in, double factor);
	
	/*!
	 * single precision sum between a scalar and a vector: vec_out = vec_in + factor
	 * @param vec_in Input vector
	 * @param factor Value to be added to 'vec_in'
	 * @return sum of vec_in and factor
	 */
	std::vector<float> Add(std::vector<float> const &vec_in, float factor);
	
	/*!
	 * complex sum between a scalar(double) and a complex vector: vec_out = vec_in + factor
	 * @param vec_in Input vector
	 * @param factor Value to be added to 'vec_in'
	 * @return sum of vec_in and factor
	 */
	std::vector<complex> Add(std::vector<complex> const &vec_in, double factor);
	
	/*!
	 * complex sum between a complex number and a complex vector: vec_out = vec_in + factor
	 * @param vec_in Input vector
	 * @param factor Value to be added to 'vec_in'
	 * @return sum of vec_in and factor
	 * @return void
	 */
	std::vector<complex> Add(std::vector<complex> const &vec_in, complex factor);
	
	/***********************************
	 *** Vector-to-Scalar Subtraction ***
	 ************************************/
	
	/*!
	 * double precision subtraction between a vector and a scalar: vec_out = vec_in - factor
	 * @param vec_in Input vector
	 * @param factor Value to be subtracted from 'vec_in'
	 * @return difference of vec_in and factor
	 */
	std::vector<double> Sub(std::vector<double> const &vec_in, double factor);
	
	/*!
	 * single precision subtraction between a vector and a scalar: vec_out = vec_in - factor
	 * @param vec_in Input vector
	 * @param factor Value to be subtracted from 'vec_in'
	 * @return difference of vec_in and factor
	 */
	std::vector<float> Sub(std::vector<float> const &vec_in, float factor);
	
	/*!
	 * complex subtraction between a vector and a scalar: vec_out = vec_in - factor
	 * @param vec_in Input vector
	 * @param factor Value to be subtracted from 'vec_in'
	 * @return difference of vec_in and factor
	 */
	std::vector<complex> Sub(std::vector<complex> const &vec_in, double factor);
	
	/*!
	 * complex subtraction between a vector and a complex number: vec_out = vec_in - factor
	 * @param vec_in Input vector
	 * @param factor Value to be subtracted from 'vec_in'
	 * @param vec_out Output vector
	 * @return void
	 */
	std::vector<complex> Sub(std::vector<complex> const &vec_in, complex factor);
	
	/********************************
	 *** Vector-to-Scalar Division ***
	 *********************************/
	
	/*!
	 * double precision division between a vector and a scalar: vec_out = vec_in/factor
	 * @param vec_in Input vector to be divided by 'factor'
	 * @param factor Denominator of the division
	 * @return division of vec_in and factor
	 */
	std::vector<double> Div(std::vector<double> const &vec_in, double factor);
	
	/*!
	 * double precision division between a vector and a scalar: vec_out = vec_in/factor
	 * @param vec_in Input vector to be divided by 'factor'
	 * @param factor Denominator of the division
	 * @return division of vec_in and factor
	 */
	std::vector<float> Div(std::vector<float> const &vec_in, float factor);
	
	/*!
	 * In-place complex division between a vector and a complex number: vec = vec/factor
	 * @param vec Vector to be divided by 'factor'
	 * @param factor Denominator of the division
	 * @return void
	 */
	std::vector<complex> Div(std::vector<complex> const &vec, complex factor);
	
	/**************************************
	 *** Vector-to-Scalar Multiplication ***
	 ***************************************/
	
	/*!
	 * double precision multiplication between a vector and a scalar: vec_out = vec_in/factor
	 * @param vec_in Input vector to be multiplied by 'factor'
	 * @param factor Multiplication factor
	 * @return multiplication of vec_in and factor
	 */
	std::vector<double> Mul(std::vector<double> const &vec_in, double factor);
	
	/*!
	 * single precision multiplication between a vector and a scalar: vec_out = vec_in/factor
	 * @param vec_in Input vector to be multiplied by 'factor'
	 * @param factor Multiplication factor
	 * @return multiplication of vec_in and factor
	 */
	std::vector<float> Mul(std::vector<float> const &vec_in, float factor);
	
	/*!
	 * complex multiplication between a vector and a scalar(complex): vec_out = vec*factor
	 * @param vec Vector to be multiplied by 'factor'
	 * @param factor Multiplication factor
	 * @param vec_out Result vector
	 * @return void
	 */
	std::vector<complex> Mul(std::vector<complex> const &vec, complex factor);
	
	
	/*!
	 * complex multiplication between a vector and a scalar(double): vec_out = vec*factor
	 * @param vec Vector to be multiplied by 'factor'
	 * @param factor Multiplication factor
	 * @param vec_out Result vector
	 * @return void
	 */
	std::vector<complex> Mul(std::vector<complex> const &vec, double factor);
	
	
	/***************************
	 *** Vector-to-Vector Sum ***
	 ****************************/
	
	/*!
	 * single precision elementwise sum between two vectors: vec_out = vec1 + vec2
	 * @param vec1 First vector of the sum and result
	 * @param vec2 Second vector of the sum
	 * @return sum of vec1 and vec2
	 */
	std::vector<float> Add(std::vector<float> const &vec1, std::vector<float> const &vec2);
	
	/*!
	 * double precision elementwise sum between two vectors: vec_out = vec1 + vec2
	 * @param vec1 First vector of the sum and result
	 * @param vec2 Second vector of the sum
	 * @return sum of vec1 and vec2
	 */
	std::vector<double> Add(std::vector<double> const &vec1, std::vector<double> const &vec2);
	
	/*!
	 * In-place complex elementwise sum between two complex vectors: vec1 = vec1 + vec2
	 * @param vec1 First vector of the sum and result
	 * @param vec2 Second vector of the sum
	 * @return void
	 */
	std::vector<complex> Add(std::vector<complex> const &vec1, std::vector<complex> const &vec2);
	
	/*!
	 * In-place complex elementwise sum between a complex vector and a double vector: vec1 = vec1 + vec2
	 * @param vec1 First vector of the sum and result
	 * @param vec2 Second vector of the sum
	 * @return void
	 */
	std::vector<complex> Add(std::vector<complex> const &vec1, std::vector<double> const &vec2);
	
	/***********************************
	 *** Vector-to-Vector Subtraction ***
	 ************************************/
	
	/*!
	 * single precision elementwise subtraction between two vectors: vec_out = vec1 - vec2
	 * @param vec1 Vector of minuends
	 * @param vec2 Vector of subtrahends
	 * @return subtraction of vec1 and vec2
	 */
	std::vector<float> Sub(std::vector<float> const &vec1, std::vector<float> const &vec2);
	
	/*!
	 * double precision elementwise subtraction between two vectors: vec_out = vec1 - vec2
	 * @param vec1 Vector of minuends
	 * @param vec2 Vector of subtrahends
	 * @param vec_out Difference vector
	 * @return subtraction of vec1 and vec2
	 */
	std::vector<double> Sub(std::vector<double> const &vec1, std::vector<double> const &vec2);
	
	/*!
	 * In-place complex elementwise subtraction between two complex vectors: vec1 = vec1 - vec2
	 * @param vec1 Vector of minuends
	 * @param vec2 Vector of subtrahends
	 * @return void
	 */
	std::vector<complex> Sub(std::vector<complex> const &vec1, std::vector<complex> const &vec2);
	
	/*!
	 * In-place complex elementwise subtraction between a complex vector and a double vector: vec1 = vec1 - vec2
	 * @param vec1 Vector of minuends
	 * @param vec2 Vector of subtrahends
	 * @return void
	 */
	std::vector<complex> Sub(std::vector<complex> const &vec1, std::vector<double> const &vec2);
	
	/********************************
	 *** Vector-to-Vector Division ***
	 *********************************/
	/*!
	 * single precision elementwise division between two vectors: num = num/den
	 * @param den Vector of divisors
	 * @param num Vector of dividends
	 * @return division of num/den
	 */
	std::vector<float> Div(std::vector<float> const &num, std::vector<float> const &den);
	
	/*!
	 * double precision elementwise division between two vectors: num = num/den
	 * @param den Vector of divisors
	 * @param num Vector of dividends
	 * @return division of num/den
	 */
	std::vector<double> Div(std::vector<double> const &num, std::vector<double> const &den);
	
	/*!
	 * In-place single precision elementwise division between two complex vectors: num = num/den
	 * @param den Vector of divisors
	 * @param num Vector of dividends
	 * @return void
	 */
	std::vector<complex> Div(std::vector<complex> const &num, std::vector<complex> const &den);
	
	/*!
	 * In-place single precision elementwise division between a complex vector and a double vector: num = num/den
	 * @param den Vector of divisors
	 * @param num Vector of dividends
	 * @return void
	 */
	std::vector<complex> Div(std::vector<complex> const &num, std::vector<double> const &den);
	
	/**************************************
	 *** Vector-to-Vector Multiplication ***
	 ***************************************/
	/*!
	 * single precision elementwise multiplication between two vectors: vec1 = vec1*vec2
	 * @param vec1 Multiplicands vector
	 * @param vec2 Multipliers vector
	 * @return elementwise product of vec1 and vec2
	 */
	std::vector<float> Mul(std::vector<float> const &vec1, std::vector<float> const &vec2);
	
	/*!
	 * double precision elementwise multiplication between two vectors: vec1 = vec1*vec2
	 * @param vec1 Multiplicands vector
	 * @param vec2 Multipliers vector
	 * @return elementwise product of vec1 and vec2
	 */
	std::vector<double> Mul(std::vector<double> const &vec1, std::vector<double> const &vec2);
	
	/*!
	 * elementwise complex multiplication between two complex vectors: vec1 = vec1*vec2
	 * @param vec1 Multiplicands vector
	 * @param vec2 Multipliers vector
	 * @return product of vec1 and vec2
	 */
	std::vector<complex> Mul(std::vector<complex> const &vec1, std::vector<complex> const &vec2);
	
	/*!
	 * elementwise complex multiplication between a complex vector and a double vector: vec1 = vec1*vec2
	 * @param vec1 Multiplicands vector (complex)
	 * @param vec2 Multipliers vector (double)
	 * @return product of vec1 and vec2
	 */
	std::vector<complex> Mul(std::vector<complex> const &vec1, std::vector<double> const &vec2); // vec1 = vec1*vec2
	
	/**************************************
	 *** Vector-to-Vector Exponentiation ***
	 ***************************************/
	/*!
	 * elementwise single precision exponentiation between vectors: vec_base = vec_base.^vec_exp
	 * @param vec_base Base vector
	 * @param vec_exp Expoent vector
	 * @return void
	 */
	std::vector<float> pow(std::vector<float> const &vec_base, std::vector<float> const &vec_exp);
	
	/*!
	 * elementwise double precision exponentiation between vectors: vec_base = vec_base.^vec_exp
	 * @param vec_base Base vector
	 * @param vec_exp Expoent vector
	 * @return void
	 */
	std::vector<double> pow(std::vector<double> const &vec_base, std::vector<double> const &vec_exp);
	
	
	/***************************************
	 ************ Absolute Value ************
	 ****************************************/
	
	/*!
	 * elementwise single precision absolut value calculation: retval = |vec|
	 * @param vec Vector
	 * @return |vec|
	 */
	std::vector<float> Abs(std::vector<float> const &vec);
	
	/*!
	 * elementwise single precision absolut value calculation: retval = |vec|
	 * @param vec Vector
	 * @return |vec|
	 */
	std::vector<double> Abs(std::vector<double> const &vec);
	
	/*!
	 * elementwise absolut value calculation of a complex vector: retval = |vec|
	 * @param vec Complex vector
	 * @return |vec|
	 */
	std::vector<double> Abs(std::vector<complex> const &vec);
	
	/**************************************
	 *********** Vector Squaring ***********
	 ***************************************/
	
	/*!
	 * single precision elementwise squaring of input vector elements: retval_j = (vec_j)^2 for all j (element-wise)
	 * @param vec Vector
	 * @return vec^2
	 */
	std::vector<float> Sq(std::vector<float> const &vec);
	
	/*!
	 * double precision elementwise squaring of input vector elements: retval_j = (vec_j)^2 for all j (element-wise)
	 * @param vec Vector
	 * @return vec^2
	 */
	std::vector<double> Sq(std::vector<double> const &vec);
	
	/*!
	 * elementwise squaring of the module of input vector elements: reval_j = (|vec_j|)^2
	 * @param vec Complex vector
	 * @return |vec|^2
	 */
	std::vector<double> SqMag(std::vector<complex> const &vec);
	
	/*************************************
	 ********* Vector Conjugation *********
	 **************************************/
	
	/*!
	 * complex conjugate of a vector: vec = vec*
	 * @param vec Input vector
	 * @return void
	 */
	std::vector<complex> Conj(std::vector<complex> const &vec); // retval = vec*
	
	/*************************************
	 ********* Vector Convolution *********
	 **************************************/
	
	/*!
	 * double precision convolution between two vectors
	 * @param signal First vector
	 * @param filter Second vector
	 * @return Convoluted Vector
	 */
	std::vector<double> Convolve(std::vector<double> const &signal, std::vector<double> const &filter);
	
	/*!
	 * single precision convolution between two vectors
	 * @param signal First vector
	 * @param filter Second vector
	 * @return Convoluted Vector
	 */
	std::vector<float> Convolve(std::vector<float> const &signal, std::vector<float> const &filter);
	
	/*************************************
	 ******** Precision Conversion ********
	 **************************************/
	/*!
	 * Precision conversion from double to float
	 * @param vec_double Input double vector
	 * @return vector of floats
	 */
	std::vector<float> double2float(std::vector<double> const &vec_double);
	
	/*!
	 * Precision conversion from float to double
	 * @param vec_float Input float vector
	 * @return vector of doubles
	 */
	std::vector<double> float2double(std::vector<float> const &vec_float);
	
	/*******************************************
	 ******** Vector to Array Conversion ********
	 ********************************************/
	
	/*!
	 * Conversion from vector to array
	 * @param vector Vector to be converted
	 * @return array Array created from 'vector'
	 */
	template<typename T>
	T* vec2array(std::vector<T> &vector)
	{
		T* array = &vector[0];
		return array;
	}
	
	/*!
	 * Conversion from array to vector
	 * @param array Array to be converted
	 * @param dim Dimension of the array (use sizeof(array)/sizeof(array[0]) if unknow)
	 * @return vec Vector created from 'array'
	 */
	template<typename T>
	std::vector<T> array2vector(T* array, int dim)
	{
		std::vector<T> vec(dim);
		std::copy(array, array + dim, vec.begin());
		return vec;
	}
	
	/*!
	 * Conversion from array to vector of vectors
	 * @param array Array to be converted
	 * @param dim Dimension of the array (use sizeof(array)/sizeof(array[0]) if unknow)
	 * @return mono_wave Vector of vectors created from 'array'. mono_wave[0] has values equal to the values from 'array'
	 */
	template<typename T>
	std::vector<std::vector<T> > array2vecvec(T* array, int dim)
	{
		std::vector<std::vector<T> > mono_wave;
		mono_wave.push_back(std::vector<T>());
		for (unsigned i = 0; i< dim; i++) {
			mono_wave[0].push_back(array[i]);
		}
		return mono_wave;
	}
	
	/*!
	 * Conversion from vector to vector of vectors
	 * @param vec Vector to be converted
	 * @return ret_vecvec Vector of vectors created from 'vector'. ret_vecvec[0] has values equal to the values from 'vec'
	 */
	template<typename T>
	std::vector<std::vector<T> > vec2vecvec(std::vector<T> vec)
	{
		std::vector<std::vector<T> > ret_vecvec;
		ret_vecvec.push_back(vec);
		return ret_vecvec;
	}
	
	/*!
	 * Conversion from vector to FTKArray
	 * @param vec Vector to be converted
	 * @return ret FTKArray created from 'vec'
	 */
	template<typename T>
	FTKArray VecToFTKArray(std::vector<T> vec)
	{
		FTKArray ret;
		
		for (int i = 0; i < vec.size(); i++) {
			ret.Append(FTKAtom(vec[i]));
		}
		
		return ret;
	}
	
	/*!
	 * Conversion from a FTKArray to a vector
	 * @param array FTKArray to be converted
	 * @return retvec Vector created from 'array'
	 */
	template<typename T>
	std::vector<T> FTKArrayToVec(FTKArray array)
	{
		std::vector<T> retvec;
		
		for (size_t i = 0; i < array.NumItems(); i++) {
			retvec.push_back(array[i].AsFloat());
		}
		
		return retvec;
	}
	
	
	/**************************************
	 ******** Amplitude/Power to Decibels **
	 ***************************************/
	
	/*!
	 * In-place single precision conversion from amplitude/power to decibels: vec = alpha*log10(|vec|/B)
	 * @param vec Amplitude or Power vector to be converted
	 * @param B Zero reference. Default = 1
	 * @param alpha 10 if Power and 20 if Amplitude. Default = 20
	 * @return vector of floats
	 */
	std::vector<float> dB(std::vector<float> const &vec, float B, int alpha = 20);
	
	/*!
	 * In-place double precision conversion from amplitude/power to decibels: vec = alpha*log10(|vec|/B)
	 * @param vec Amplitude or Power vector to be converted
	 * @param B Zero reference. Default = 1
	 * @param alpha 10 if Power and 20 if Amplitude. Default = 20
	 * @return vector of doubles
	 */
	std::vector<double> dB(std::vector<double> const &vec, double B, int alpha = 20);
	
	/*****************************
	 ******** Find Max/Min ********
	 ******************************/
	
	/*!
	 * Find maximum value of a vector
	 * @param vec Vector to search for maximum
	 * @return maximum value
	 */
	template<typename T>
	T
	Max(std::vector<T> const &vec)
	{
		return *std::max_element(vec.begin(), vec.end());
	}
	
	/*!
	 * Find greatest absolute value element of a vector
	 * @param vec Vector to search for maximum
	 * @return element with maximum absolute value
	 */
	template<typename T>
	T
	AbsMax(std::vector<T> const &vec)
	{
		return *std::max_element(vec.begin(), vec.end(), AbsComparator<T>());
	}
	
	/*!
	 * Find minimum value of a vector
	 * @param vec Vector to search for maximum
	 * @return minimum value
	 */
	template<typename T>
	T
	Min(std::vector<T> const &vec)
	{
		return *std::min_element(vec.begin(), vec.end());
	}
	
	/*!
	 * Find smaller absolute value element of a vector
	 * @param vec Vector to search for maximum
	 * @return element with smaller absolute value
	 */
	template<typename T>
	T
	AbsMin(std::vector<T> const &vec)
	{
		return *std::min_element(vec.begin(), vec.end(), AbsComparator<T>());
	}
	
	
	/*************************
	 ******** Clipping ********
	 **************************/
	
	/*!
	 * Clip elements of a float vector.
	 * If an element of 'vec' is greater than 'upper_limit' it will be substituted by 'upper_limit'.
	 * If an element of 'vec' is smaller than 'lowe_limit' it will be substituted by 'lower_limit'
	 * @param vec Vector to be clipped
	 * @param upper_limit Maximum value allowed on the clipped vector
	 * @param lower_limit Minimum value allowed on the clipped vector
	 */
	std::vector<float> Clip(std::vector<float> const &vec, float upper_limit, float lower_limit);
	
	/*!
	 * Clip elements of a double vector.
	 * If an element of 'vec' is greater than 'upper_limit' it will be substituted by 'upper_limit'.
	 * If an element of 'vec' is smaller than 'lowe_limit' it will be substituted by 'lower_limit'
	 * @param vec Vector to be clipped
	 * @param upper_limit Maximum value allowed on the clipped vector
	 * @param lower_limit Minimum value allowed on the clipped vector
	 */
	std::vector<double> Clip(std::vector<double> const &vec, double upper_limit, double lower_limit);
	
	/******************************
	 ******** Normalization ********
	 *******************************/
	
	
	/*!
	 * Find index of the closest value of 'val' in 'vec'
	 * @param vec Vector to search for value
	 * @param val value to search for
	 * @return index of value in 'vec' that is closest to 'val'
	 */
	template<typename T>
	size_t
	ClosestValueIdx(std::vector<T> const vec, T val)
	{
		size_t pos;
		std::vector<T> vec_aux(vec.size());
		vec_aux = VectOp::Sub(vec, val);
		vec_aux = VectOp::Abs(vec_aux);
		pos = std::distance(vec_aux.begin(), std::min_element(vec_aux.begin(), vec_aux.end()));
		return pos;
	}
	
	/*!
	 * In-place
	 * Normalize vector to have values between -limit and limit
	 * @param vec Vector to be normalized
	 * @param limit Normalization factor
	 * @return void
	 */
	template<typename T>
	void
	normalize(std::vector<T> &vec, T limit=1)
	{
		T max = AbsMax(vec);
		VectOp::Div(vec,(max/limit));
	}
	
	/*!
	 * In-place
	 * Normalize vector to have, in dB, values smaller than limitdb.
	 * @param vec Vector to be normalized
	 * @param limitdb Normalization factor
	 * @return void
	 */
	template<typename T>
	void
	normalizedB(std::vector<T> &vec, T limitdb=0)
	{
		T limit = pow(10,limitdb/20);
		normalize(vec, limit);
	}
	
	/*!***********************
	 ******** Statistics ******
	 **************************/
	/*!
	 * Find mean value of a vector of numbers
	 * @param vec Vector to be averaged
	 * @return retval Mean value
	 */
	float					Mean(std::vector<int> &vec);
	
	/*!
	 * Find mean value of a vector of numbers
	 * @param vec Vector to be averaged
	 * @return retval Mean value
	 */
	float					Mean(std::vector<float> &vec);
	
	/*!
	 * Find mean value of a vector of numbers
	 * @param vec Vector to be averaged
	 * @return retval Mean value
	 */
	double					Mean(std::vector<double> &vec);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	float					Var(std::vector<int> &vec);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	float					Var(std::vector<int> &vec, float mean);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	float					Var(std::vector<float> &vec);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	float					Var(std::vector<float> &vec, float mean);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	double					Var(std::vector<double> &vec);
	
	/*!
	 * Find variance of a vector of numebers
	 * @param vec Vector
	 * @return retval Variance
	 */
	double					Var(std::vector<double> &vec, double mean);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					Stdev(std::vector<int> &vec);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					Stdev(std::vector<int> &vec, float mean);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					Stdev(std::vector<float> &vec);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					Stdev(std::vector<float> &vec, float mean);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	double					Stdev(std::vector<double> &vec);
	
	/*!
	 * Find standard deviation of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	double					Stdev(std::vector<double> &vec, double mean);
	
	/*!
	 * Find RMS value of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					RMS(std::vector<int> &vec);
	
	/*!
	 * Find RMS value of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	float					RMS(std::vector<float> &vec);
	
	/*!
	 * Find RMS value of a vector of numebers
	 * @param vec Vector
	 * @return retval Standard deviation
	 */
	double					RMS(std::vector<double> &vec);
	
	/****************************************
	 ******** Solving Linear Systems ********
	 ****************************************/
	
	/*!
	 * Solves Ax = b
	 * @param A Matrix on the lhs of the linear system to be solved
	 * @param b Vector on the rhs of the linear system
	 * @return x Result vector
	 */
	std::vector<float>
	linsolve(std::vector<std::vector<float> > A, std::vector<float> b);
	
	/*******************************
	 ******** Least Squares ********
	 *******************************/
	
	/*!
	 * Solves AX = b
	 * @param A Matrix on the lhs of the linear system to be solved
	 * @param b Vectors on the rhs of the linear system
	 * @return x Least square solution to the under/overdetermined problem.
	 */
	std::vector<float>
	vec_least_squares(std::vector<float> A, std::vector<float> b, int vrows, int vcols, int vnrhs);
	
//	std::vector<std::vector<float> >
//	least_squares(std::vector<std::vector<float> > A, std::vector<std::vector<float> > b);
	
	
	/*************************
	 ******** Derivatives *****
	 **************************/
	
	/*!
	 * Find n-th order discrete difference
	 * @param vec Vector that you yant to differentiate
	 * @order order Discrete difference order, must be greater than 0
	 * return n-th order discrete difference
	 */
	template<typename T>
	std::vector<T>
	diff(std::vector<T> &vec, int order = 1)
	{
		std::vector<T> a(vec.begin(),vec.end()-1);
		std::vector<T> b(vec.begin()+1,vec.end());
		if (order == 0 ) {
			return a;
			
		} else if (order == 1) {
			b = VectOp::Sub(b, a);
			return b;
		} else if (order > 1) {
			b = VectOp::Sub(b, a);
			return diff(b, order-1);
		} else {
			std::cout << "Must be greater than 0..." << std::endl;
			return std::vector<T>();
		}
	}
	
	// Elements sum
	/*!
	 * Perform sum of the elements of a vector
	 * @param vec Vector to have elements summed
	 * @return Sum of the elements of the vector
	 */
	
	// FIXME: should go to VectorUtils
	template<typename T>
	T
	ElSum(std::vector<T> vec)
	{
		T retval = 0;
		for (size_t i = 0; i < vec.size(); i++) {
			retval += vec[i];
		}
		
		return retval;
	}
	
	/**************************
	 ******** Square Root *****
	 **************************/
	
	/*!
	 * Element-wise square root of a vector.
	 * @param vec
	 *  Vector to take square root of
	 * @return sqrtvec
	 *	 Vector with square-rooted elements
	 */
	template <typename T>
	std::vector<T>
	sqrt(std::vector<T> vec)
	{
	 std::vector<T> sqrtvec;
	 
	 for (size_t i = 0; i < vec.size(); i++) {
		 sqrtvec.push_back(std::sqrt(vec[i]));
	 }
	 
	 return sqrtvec;
	 
	}
	
	// log
	
	/*!
	 * Element-wise log of a vector
	 * @param vec
	 *  Vector to be log-ed
	 * @return logvec
	 *  Vector with log-ed elements
	 */
	template <typename T>
	std::vector<T>
	log(std::vector<T> vec)
	{
		std::vector<T> logvec;
		
		for (size_t i = 0; i < vec.size(); i++) {
			logvec.push_back(std::log(vec[i]));
		}
		
		return logvec;
	}
	
	// Printing stuff
	/*!
	 * Print a matrix in a nice format
	 *
	 * @param v
	 *	matrix to be printed
	 */
	template <typename T>
	void
	print_matrix(std::vector<std::vector<T> > v, bool print_size = true)
	{
		if (print_size) {
			std::cout << "Matrix size: " << v.size() << "x" << v[1].size() << std::endl;
		}
		
		for ( size_t i = 0; i < v.size(); i++ )
		{
			
			for ( size_t j = 0; j < v[i].size(); j++ )
			{
				std::cout << v[i][j] << ",\t";
			}
			std::cout << "\n";
		}
	}
	
	/*!
	 * Print a vector in a nice format
	 *
	 * @param v
	 *	vector to be printed
	 */
	
	template <typename T>
	void
	print_vector(std::vector<T> v, bool print_size = true)
	{
		if (print_size) {
			std::cout << "Vector size: " << v.size() << "\n";
		}
		
		for ( size_t i = 0; i < v.size(); i++ )
		{
			std::cout << v[i] << ',';
		}
		std::cout << "\n";
	}
	
	
	// Matrix operations
	
	/*!
	 * Transformation of a vector of vectors to a vector for a given number of rows and columns.
	 *
	 * @param matrix
	 *	Vector of vectors to be linearized
	 * @param rows
	 *	Number of rows to be used
	 * @param cols
	 *	Number of columns to be used
	 * @return retvec
	 *	Vector with the original matrix elements. retvec[i*rows + j] = matrix[j][i].
	 */
	
	template <typename T>
	std::vector<T>
	linearize_matrix(std::vector<std::vector<T> > matrix, size_t rows, size_t cols) {
		
		std::vector<T> retvec(rows*cols);
		
		for (size_t i = 0; i < cols; i++) {
			for (size_t j = 0; j < rows; j++) {
				retvec[i*rows + j] = matrix[j][i];
			}
		}
		return retvec;
	}
	
	/*!
	 * Transformation of a vector of vectors to a vector following retvec[i*rows + j] = matrix[j][i].
	 *
	 * @param matrix
	 *	Vector of vectors to be linearized
	 * @return retvec
	 *	Vector with the original matrix elements.
	 */
	
	template <typename T>
	std::vector<T>
	linearize_matrix(std::vector<std::vector<T> > matrix) {
		
		size_t rows = matrix.size();
		size_t cols = matrix[0].size();
		
		std::vector<T> retvec(rows*cols);
		
		for (size_t i = 0; i < cols; i++) {
			for (size_t j = 0; j < rows; j++) {
				retvec[i*rows + j] = matrix[j][i];
			}
		}
		return retvec;
	}
	
	/*!
	 * Average a vector of matrices. Equivalent to MatLab mean(X,3)
	 *
	 * @param cube
	 *	Vector of vector of vectors to be averaged
	 * @return average
	 *	Matrix of averaged values
	 */
	template <typename T>
	std::vector<std::vector<float> >
	cube_z_average(std::vector<std::vector<std::vector<T> > > cube)
	{
		size_t x_size = cube[0][0].size();
		size_t y_size = cube[0].size();
		size_t z_size = cube.size();
		
		std::vector<std::vector<float> > average(y_size, std::vector<float>(x_size));;
		
		for (size_t x = 0; x < x_size; x++) {
			for (size_t y = 0; y < y_size; y++) {
				for (size_t z = 0; z < z_size; z++) {
					average[y][x] += cube[z][y][x]/(float)z_size;
				}
			}
		}
		
		return average;
	}
	
	/*!
	 * Transformation of mxn elements of a vector into a mxn vector of vectors.
	 *
	 * @param vec
	 *	Vector to be put into matrix
	 * @param rows
	 *	Number of rows of the equivalent matrix
	 * @param cols
	 *	Number of columns of the equivalent matrix
	 * @return retmatrix
	 * Matrix generated by vec with size rowsxcols. retmatrix[j][i] = vec[i*rows + j]
	 */
	
	template <typename T>
	std::vector<std::vector<T> >
	vector_to_matrix(std::vector<T> vec, size_t rows, size_t cols) {
		
		std::vector<std::vector<T> > retmatrix = std::vector<std::vector <T> >(rows, std::vector<T>());
		
		for (size_t i = 0; i < cols; i++) {
			for (size_t j = 0; j < rows; j++) {
				retmatrix[j].push_back(vec[i*rows + j]);
			}
		}
		return retmatrix;
	}
	
	// FIXME: header docs here
	template <typename T, typename P>
	std::vector<std::vector<T> >
	recast_matrix(std::vector<std::vector<P> > matrix)
	{
		std::vector<P> matrix_linear = VectOp::linearize_matrix(matrix);
		std::vector<T> matrix_T_linear(matrix_linear.begin(), matrix_linear.end());
		std::vector<std::vector<T> > recasted_matrix = VectOp::vector_to_matrix(matrix_T_linear, matrix.size(), matrix[0].size());
		return recasted_matrix;
	}
	
	/*!
	 * Transpose a vector of vectors
	 *
	 * @param matrix
	 *	Vector of vectores to be transposed
	 * @return transpose
	 *	Transposed matrix
	 */
	// FIXME: not really elegant, there may be a better way to do it
	template <typename T>
	std::vector<std::vector<T> >
	transpose(std::vector<std::vector<T> > matrix)
	{
		std::vector<std::vector<T> > transpose(matrix[0].size(),std::vector<T>(matrix.size()));
		
		for (size_t i = 0; i < matrix.size(); i++) {
			for (size_t j = 0; j < matrix[0].size(); j++) {
				transpose[j][i] = matrix[i][j];
			}
		}
		return transpose;
	}
	
	/*!
	 * Average matrix row by row
	 * @param matrix
	 *  Matrix to be averaged
	 *
	 * @return retvec
	 *  Vector with rows average
	 */
	template <typename T>
	std::vector<T>
	matrix_row_average(std::vector<std::vector<T> > matrix)
	{
		std::vector<T> retvec;
		for (size_t i = 0; i < matrix.size(); i++) {
			retvec.push_back(VectOp::Mean(matrix[i]));
		}
		
		return retvec;
	}
	
	/*!
	 * Average matrix column by column
	 * @param matrix
	 *  Matrix to be averaged
	 *
	 * @return retvec
	 *  Vector with columns average
	 *
	 */
	template <typename T>
	std::vector<T>
	matrix_col_average(std::vector<std::vector<T> > matrix)
	{
		return matrix_row_average(transpose(matrix));
	}
	
	/*!
	 * Cartesian grid in 2D space
	 * @param x
	 *	Vector to be replicated y.size() times to form the columns of X
	 * @param y
	 *	Vector to be replicated x.size() times to form the rows of Y
	 * @return (X,Y)
	 *	A std::pair of vectors of vectors with the generated grid
	 */
	template <typename T>
	std::pair<std::vector<std::vector<T> >, std::vector<std::vector<T> > >
	meshgrid(std::vector<T> x, std::vector<T> y)
	{
		std::vector<std::vector<T> > X;
		std::vector<std::vector<T> > Y(y.size(),std::vector<T>(x.size()));
		
		for (size_t i = 0; i < y.size(); i++) {
			X.push_back(x);
		}
		
		for (size_t i = 0; i < y.size(); i++) {
			Y[i] =  std::vector<T> (x.size(),y[i]);
		}
		
		return std::pair<std::vector<std::vector<T> >, std::vector<std::vector<T> > > (X,Y);
	}
	
	/*!
	 * Calculate distance matrix and condense it into a short format. A distance matrix is symmetrical and the diagonal elements are 0. The returned vector is composed by the lower triangle of the distance matrix using Fortran (column, MatLab) convention.
	 *
	 * @param x
	 *  Vector of x coordinates
	 * @param y
	 *  Vector of y coordinates
	 * @return symmetric_matrix;
	 *  Vector with short-form distance matrix
	 */
	template <typename T>
	std::vector<float>
	distance_matrix_shortform(std::vector<T> x, std::vector<T> y)
	{
		size_t n = x.size();
		
		std::vector<float> symmetric_matrix;
		
		for (size_t i = 0; i < n - 1; i++) {
			for (size_t j = i+1; j < n; j++) {
				symmetric_matrix.push_back(std::sqrt(std::pow((x[j] - x[i]),2) + std::pow((y[j] - y[i]),2)));
			}
		}
		
		return symmetric_matrix;
	}
	
	/*!
	 * Unpack a symmetric matrix put in a short format. The short format excludes the diagonal and list the lower triangle using Fortran (column, MatLab) convention.
	 * @param short_form
	 *	 Vector with symmetric matrix short form
	 * @param diagonal_value
	 *	 Value for the diagonal of the symmetric matrix
	 * @return matrix
	 *  Full symmetric matrix (vector of vectors)
	 */
	template <typename T>
	std::vector<std::vector<T> >
	unpack_symmetric_matrix(std::vector<T> short_form, T diagonal_value = 0)
	{
		size_t n = (std::sqrt(8*short_form.size()+1) + 1)/2;
		
		std::vector<std::vector<float> > matrix(n,std::vector<float>(n,diagonal_value));
		
		size_t k = 0;
		for (size_t i = 0; i < n - 1; i++) {
			for (size_t j = i+1; j < n; j++) {
				matrix[i][j] = short_form[k];
				matrix[j][i] = matrix[i][j];
				k++;
			}
		}
		
		VectOp::print_matrix(matrix);
		
		return matrix;
	}
    /*!
     * Do linear regression on a pair of vectors, returns a 3 element vector with the slope, y-intercept and coefficient of determination (r)
     * @param x X axis vector
     * @param y Y axis vector
     * @return 3 element vector with the slope, y-intercept and coefficient of determination (r)
     */
    template<typename T>
    std::vector<double>
    linfit(std::vector<T> &x, std::vector<T> &y)
    {
        std::vector<double> retvec;
        size_t n = x.size();
        std::vector<T> xy;
        std::vector<T> xx;
        std::vector<T> yy;
        double b, m;
        T sy = 0.0,
        sxy = 0.0,
        sxx = 0.0,
        sx =0.0,
        syy = 0.0;
        
        sx = VectOp::ElSum(x);
        sy = VectOp::ElSum(y);
        VectOp::Mul(x,y,xy);
        sxy = VectOp::ElSum(xy);
        
        
        xx = VectOp::Sq(x);
        sxx = VectOp::ElSum(xx);
        
        yy = VectOp::Sq(y);
        syy = VectOp::ElSum(yy);
        
        double denom = (n * sxx - sx*sx);
        m = (n * sxy  -  sx * sy) / denom;
        b = (sy * sxx  -  sx * sxy) / denom;
        double r;
        r = (sxy - sx * sy / n) / sqrt((sxx - sx*sx/n) * (syy - sy*sy/n));
        
        
        retvec.push_back(m);
        retvec.push_back(b);
        retvec.push_back(r);
        
        return retvec;
    }
    
    template<typename T>
    double
    RTO(std::vector<T> &x, std::vector<T> &y)
    {
        std::vector<T> yl(y.begin(),y.end());
        std::vector<T> xx(x.begin(),x.end());
        std::vector<T> xyl(x.begin(),x.end());
        
        double num, den;
        
        VectOp::Sub(yl, y, y[0]);
        
        xx = VectOp::Sq(x);
        VectOp::Mul(xyl, yl);
        
        num = VectOp::ElSum(xyl);
        std::cout << "<!!!> num: " << num << std::endl;
        den = VectOp::ElSum(xx);
        std::cout << "<!!!> den: " << den << std::endl;
        return num/den;
    }
	
	
}
#endif /* defined(__AudioTools__VectorUtils__) */

