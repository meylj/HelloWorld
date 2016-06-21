//
//  nDvectorsUtils.h
//  VectorUtils
//
//  Created by Aliel Kauchakje Pedrosa on 3/5/15.
//  Copyright (c) 2015 Aliel Kauchakje Pedrosa. All rights reserved.
//

#ifndef __VectorUtils__nDvectorsUtils__
#define __VectorUtils__nDvectorsUtils__

#include <stdio.h>
#include "nDvectors2.h"

enum operation_t {
MAX,
MIN,
ABSMAX,
ABSMIN
};

template <typename T>
nDvector<T>
sqrt(nDvector<T> vector) {
	nDvector<T> ret_vector(vector.get_dimension(), VectOp::sqrt(vector.get_linear_form()));
	return ret_vector;
}

template <typename T>
nDvector<T>
square(nDvector<T> vector) {
	nDvector<T> ret_vector(vector.get_dimension(), VectOp::Sq(vector.get_linear_form()));
	return ret_vector;
}

template <typename T>
float
rms(nDvector<T> vector)
{
	return sqrt(square(vector).mean());
}

template <typename T>
nDvector<float>
rms(nDvector<T> vector, size_t dimension)
{
	return sqrt(square(vector).mean(dimension));
}

template <typename T>
T
max(nDvector<T> vector) {
	return VectOp::Max(vector.get_linear_form());
}

template <typename T>
T
min(nDvector<T> vector) {
	return VectOp::Min(vector.get_linear_form());
}

template <typename T>
T
absmax(nDvector<T> vector) {
	return VectOp::AbsMax(vector.get_linear_form());
}

template <typename T>
T
absmin(nDvector<T> vector) {
	return VectOp::AbsMin(vector.get_linear_form());
}


/// !!!: plans for extending this function: reshape a nD vector to a 2D vector, divide, reshape back to nD... for now only 2D vectors (matrices) accepted. Also, this function is preatty easy to optimize.
template <typename T>
nDvector<T>
divide_matrix_line_by_line(nDvector<T> matrix, std::vector<T> factor) {
//check if it's a matrix
	assert(matrix.get_dimension().size() == 2);
	assert(factor.size() == matrix.get_dimension()[0]);
	
	std::vector<T> aux_vector = matrix.get_linear_form();
	
	for (size_t i = 0; i < aux_vector.size(); i++) {
		aux_vector[i] /= factor[i%factor.size()];
	}
	
	nDvector<T> retvec(matrix.get_dimension(), aux_vector);
	
	return retvec;
	
}

template <typename T>
nDvector<T>
multiply_matrix_line_by_line(nDvector<T> matrix, std::vector<T> factor) {
	//check if it's a matrix
	assert(matrix.get_dimension().size() == 2);
	assert(factor.size() == matrix.get_dimension()[0]);
	
	std::vector<T> aux_vector = matrix.get_linear_form();
	
	for (size_t i = 0; i < aux_vector.size(); i++) {
		aux_vector[i] *= factor[i%factor.size()];
	}
	
	nDvector<T> retvec(matrix.get_dimension(), aux_vector);
	
	return retvec;
	
}

template <typename T>
nDvector<T>
oneD_operation(nDvector<T> vector, size_t dimension, operation_t option) {
	
	std::vector<size_t> order = VectOp::Range((size_t) 1, (size_t) vector.get_dimension().size(), (size_t) 1);
	
	order.insert(order.begin(), dimension);
	
	order.erase(order.begin() + dimension);
	
	std::vector<size_t> dimensions = vector.get_dimension();
	
	size_t group_size = dimensions[dimension - 1];
	
	dimensions.erase(dimensions.begin() + dimension - 1);
	
	nDvector<T> permuted_vector = vector.permute(order);
	
	std::vector<T> linear_form = permuted_vector.get_linear_form();
	
	std::vector<T> operation_vector;
	
	for (size_t i = 0; i < linear_form.size()/group_size; i++) {
		std::vector<T> aux(linear_form.begin() + i*group_size, linear_form.begin() + (i+1)*group_size);
		switch (option) {
			case MAX:
				operation_vector.push_back(VectOp::Max(aux));
				break;
			case MIN:
				operation_vector.push_back(VectOp::Min(aux));
				break;
			case ABSMAX:
				operation_vector.push_back(VectOp::AbsMax(aux));
			    break;
			case ABSMIN:
				operation_vector.push_back(VectOp::AbsMin(aux));
				break;
			default:
				operation_vector.push_back(VectOp::Max(aux));
				break;
		}
		
	}
	
	nDvector<T> retvector(dimensions, operation_vector);
	
	return retvector;
}

template <typename T>
nDvector<T>
max(nDvector<T> vector, size_t dimension) {
	return oneD_operation(vector, dimension, MAX);
}

template <typename T>
nDvector<T>
min(nDvector<T> vector, size_t dimension) {
	return oneD_operation(vector, dimension, MIN);
}

template <typename T>
nDvector<T>
maxabs(nDvector<T> vector, size_t dimension) {
	return oneD_operation(vector, dimension, ABSMAX);
}

template <typename T>
nDvector<T>
minabs(nDvector<T> vector, size_t dimension) {
	return oneD_operation(vector, dimension, ABSMIN);
}

template <typename T>
nDvector<T>
divide_elementwise(nDvector<T> vector_num, nDvector<T> vector_den) {
	
	assert(vector_num.size() == vector_den.size());
	
	std::vector<size_t> dimensions_num = vector_num.get_dimension();
	std::vector<size_t> dimensions_den = vector_den.get_dimension();
	for (size_t i = 0; i < dimensions_num.size(); i++) {
		assert(dimensions_num[i] == dimensions_den[i]);
	}
	
	std::vector<T> quotient = VectOp::Div(vector_num.get_linear_form(), vector_den.get_linear_form());
	
	nDvector<T> retnDvector(dimensions_num, quotient);
	
	return retnDvector;
}

template <typename T>
nDvector<T>
abs(nDvector<T> vector)
{
	std::vector<T> abs_vector = VectOp::Abs(vector.get_linear_form());
	nDvector<T> abs_nDvector(vector.get_dimension(), abs_vector);
	return abs_nDvector;
}

template <typename T>
nDvector<T>
var(nDvector<T> vector)
{
	return square(vector).mean() - square(vector.mean());
}

template <typename T>
nDvector<T>
var(nDvector<T> vector, size_t dimension)
{
	return square(vector).mean(dimension) - square(vector.mean(dimension));
}

template <typename T>
nDvector<T>
stdev(nDvector<T> vector)
{
	return sqrt(var(vector));
}

template <typename T>
nDvector<T>
stdev(nDvector<T> vector, size_t dimension)
{
	return sqrt(var(vector, dimension));
}

nDvector<float>		nDleast_squares(nDvector<float> A, nDvector<float> b);

#endif /* defined(__VectorUtils__nDvectorsUtils__) */
