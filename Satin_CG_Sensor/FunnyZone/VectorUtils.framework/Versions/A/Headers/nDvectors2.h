//
//  nDvectors2.h
//  VectorUtils
//
//  Created by Aliel Kauchakje Pedrosa on 3/2/15.
//  Copyright (c) 2015 Aliel Kauchakje Pedrosa. All rights reserved.
//
// FAQ (not really, noone never asked me a question, so those are the questions I assume that may arise)
//
// Q: Why everything on the .h? Why not use a cpp?
// A: Most part of this code is done throught templates. Templates are not functions. You can read more here:
//	http://isocpp.org/wiki/faq/templates#templates-defn-vs-decl
//
// Q: Are you dumb, Aliel? Why is this file called nDvectors2.h if we don't have a nDvectors1.h or nDvectors.h?
// A1: We are free to chose the name we want.
// A2: There was a nDvectors.h and for exoteric reasons xcode didn't like it then I copied and pasted it to nDvectors2 and life was happy again.
//
// Q: Are you sure this work?
// A: I have tested the functions using some examples and comparing with MATLAB. Corner cases may arise. Unit test is needed to make sure everything is actually working properly.
//
// Q: Why are you passing dimensions as a vector and not as an array?
// A1: Because I want to. =)
// A2: Because there is no practical way to now the size of the array without passing also the size, but passing the size makes the syntax confusing and complicated - and no, doing sizeof(array)/sizeof(array[0]) doesn't work inside the function.
// A3: The idea for the future is to use variadic templates to access everything. Passing vectors is just a temporary thing.
// A4: It works fine, you can define your vector using arrays if you think it's convenient.
//
// Q: Who needs this and why?
// A1: Noone NEEDS it, you only NEED water, food and air.
// A2: Having a framework to operate with n-dimensional arrays makes conversion of MATLAB code to C++ much more easy.
//
// Q: Then use Eigen! Or Boost!
// A1: And how about the fun of making this?
// A2: Eigen is great. Really fast and reliable. The problem is to make it work with Euphony and having full control of all dependencies.
// A3: Boost is a behemoth, it has it's own syntax. Better to avoid it.
//
// Q: How do you operate with n-dimensional vectors.
// A: Just do a 1-D vector and index the indices right.
//
// Q: Are all the algorithms optmial?
// A: Definitely not.
//
// Q: Are you trying to optimize it?
// A: Yes. Slowly. No premature optimization - let's make sure it works first.
//
// Q: Why the methods/functions are so poorly named?
// A: Because I am a poor "namer".



#ifndef __VectorUtils__nDvectors2__
#define __VectorUtils__nDvectors2__

#include <assert.h>
#include <stdio.h>

#include <vector>
#include <numeric>
#include <algorithm>

#include "VectorUtils.h"


static
std::vector<std::vector<size_t> > combinations(size_t size, std::vector<size_t> dim ) {
	
	std::vector<std::vector<size_t> > combs(dim.size());
	
	for (size_t i = 0; i < dim.size(); i++) {
		size_t jmp;
		
		if (i != dim.size() - 1) {
			jmp = std::accumulate (dim.begin() + i + 1, dim.end(), 1, std::multiplies<int>());
		} else {
			jmp = 1;
		}
		
		size_t reps = size/jmp;
		size_t count = 0;
		for(size_t j = 0; j < reps; j++) {
			std::vector<size_t> aux(jmp,count);
			count++;
			count %= dim[i];
			combs[i].insert(combs[i].end(), aux.begin(), aux.end());
		}
	}
	
	return combs;
}

static
std::vector<std::vector<size_t> > perm_rows(std::vector<std::vector<size_t> > matrix, std::vector<size_t> order)
{
	assert(matrix.size() == order.size());
	
	std::vector<std::vector<size_t> > ret_matrix;
	
	for (size_t i = 0; i < order.size(); i++) {
		ret_matrix.push_back(matrix[order[i] - 1]);
	}
	
	return ret_matrix;
}

/*!
 * @class nDvector
 * N-dimensional arrays
 */
template <typename T>
class
nDvector : public std::vector<T>
{
protected:
//private:
public:
	std::vector<size_t> m_dimensions;
	std::vector<int> m_vector_element_idx;
	
	size_t m_size;
	
	size_t m_idx = 0;
	
	size_t m_count = 0;

	size_t element_idx(std::vector<size_t> position) {
		
		m_idx = 0;
		
		m_dimensions.insert(m_dimensions.begin(), 1);
		
		for (int i = (int)(position.size() - 1); i >= 0; --i) {
			m_idx += position[i];
			m_idx *= m_dimensions[i];
		}
		m_dimensions.erase(m_dimensions.begin());
		
		return m_idx;
	}
	/*!
	 * Index of the linear equivalent vector given a n-D index and the dimension of the vector
	 * @param vector_element_idx	n-dimensional index (n1, n2, n3, ... nm)
	 * @param dimensions	dimensions of the vector we want find the index
	 * @return m_idx		index of the equivalent linear vector to the n-dimensional vector in use
	 */
	size_t
	element_idx(std::vector<size_t> vector_element_idx, std::vector<size_t> dimensions)
	{
		size_t idx;
		dimensions.insert(dimensions.begin(), 1);
		
		for (int i = (vector_element_idx.size() - 1); i >= 0; --i) {
			idx += vector_element_idx[i];
			idx *= dimensions[i];
		}
		dimensions.erase(dimensions.begin());
		vector_element_idx.clear();

		return m_idx;

	}

	template <typename N> size_t
	element_idx(N t) {
		
		m_vector_element_idx.push_back(t);
		
		if ((t > m_dimensions[m_vector_element_idx.size() - 1] -1) || (t < 0) || m_vector_element_idx.size() > m_dimensions.size()) {
			fprintf(stderr, "Cannot access dimension %lu. Trying to access element %d of %lu.\n", m_vector_element_idx.size(), t + 1, m_dimensions[m_vector_element_idx.size() - 1]);
			m_vector_element_idx.clear();
			exit(EXIT_FAILURE);
		}
		
		m_dimensions.insert(m_dimensions.begin(), 1);
		
		for (int i = (m_vector_element_idx.size() - 1); i >= 0; --i) {
			m_idx += m_vector_element_idx[i];
			m_idx *= m_dimensions[i];
		}
		m_dimensions.erase(m_dimensions.begin());
		m_vector_element_idx.clear();
		m_count = 0;
		return m_idx;
	}
	
	/*!
	 * Variadic template to find the index of a n-dimensional vector element in it's equivalent linear form
	 * @param n-dimensional index (n1, n2, n3, ..., nm)
	 * @return m_idx linear form index of a n-dimensional vector element
	 */
	template <typename N, typename ...P> size_t
	element_idx(N t, P ...p) {
		m_idx = 0;
		m_count ++;
		if (m_count == 1) {
			if (sizeof...(p) != m_dimensions.size() - 1) {
				fprintf(stderr, "Error. Dimension mismatch.\n");
				exit(EXIT_FAILURE);
			}
		}
		
		if (sizeof...(p))
		{
			m_vector_element_idx.push_back(t);
			
			if ((t > m_dimensions[m_vector_element_idx.size() - 1] -1) || (t < 0) || m_vector_element_idx.size() > m_dimensions.size()) {
				fprintf(stderr, "Cannot access dimension %lu. Trying to access element %d of %lu.\n", m_vector_element_idx.size(), (int)(t + 1), m_dimensions[m_vector_element_idx.size() - 1]);
				m_vector_element_idx.clear();
				exit(EXIT_FAILURE);
			}
			
			t = element_idx(p...);
		}
		
		return m_idx;
	}
//public:
	std::vector<T> m_nDvector_linear; // main star of this show, public for now, not sure later

// Constructors
	nDvector() {};
	nDvector<T>(const std::vector<size_t>,const int = 0);
	nDvector<T>(const std::vector<size_t>,const std::vector<T>);
	
// Little destructor
	~nDvector<T>() {};
	
// Basic functions
	std::vector<size_t> get_dimension() const;
	std::vector<T> get_linear_form() const;
	nDvector<T> get_subnDvector(const std::vector<size_t>& position); // use full dimensions as MatLab :
	nDvector<T> get_submatrix(const size_t position_dimension_x, const size_t position_dimension_y, const std::vector<size_t>& position);
	size_t size() const;

// Handy functions
	T sum();
	nDvector<T> sum(size_t dim);
	
	float mean();
	nDvector<float> mean(size_t dim);
	
	nDvector<T> reshape(std::vector<size_t> new_dimensions);
	
	nDvector<T> permute(std::vector<size_t> order);
	
	nDvector<T> inverse_permute(std::vector<size_t> order);
	
	nDvector<T> transpose();
	nDvector<T> permute2D();
	nDvector<T> permute2D(std::vector<size_t> order);
	
// !!!: implement
	nDvector<T> permute3D(std::vector<size_t> order);
	
	nDvector<T> repeat(size_t repeat, size_t dimension);
	
	void print() {
		fprintf(stderr,"Vector dimension: ");
		VectOp::print_vector(m_dimensions, false);
		fprintf(stderr,"Vector content:\n");
		VectOp::print_vector(m_nDvector_linear, false);
	};
	
	void vector_fill(const std::vector<T> vector);
	void matrix_fill(const std::vector<std::vector<T> > matrix);
	void matrix_fill(const nDvector<T> matrix, const size_t position_dimension_rows, const size_t position_dimension_cols, const std::vector<size_t>& position);
	void matrix_fill(const std::vector<std::vector<T> > matrix, const size_t position_dimension_x, const size_t position_dimension_y, const std::vector<size_t>& position); // do it as variadic template, you lazy boy.
	
	nDvector<T> nDvector_fill(const std::vector<size_t>& position);
	
	template <typename N, typename ...P> T&
	operator()(const N t, const P ...p) {
		return m_nDvector_linear[element_idx(t, p...)];
	}

	//	nDvector<T> operator*|(const nDvector<T>& v2);
};

/*!
 * nDvector constructor using dimensions and a constant. Initialize a n-dimensional vector with the number n.
 * @param dim	vector with the dimenions of the n-dimensional vector
 * @param n		initial value for all elements of the n-dimensional vector
 */
template <typename T>
nDvector<T>::nDvector (const std::vector<size_t> dim, const int n)
{
	m_dimensions = dim;
	m_size = std::accumulate (dim.begin(), dim.end(), 1, std::multiplies<int>());

	assert(m_size != 0);
	
	m_nDvector_linear = std::vector<T>(m_size,n);
}

/*!
 * nDvector constructor using dimensions and std vector.
 * @param dim		vector with the dimenions of the n-dimensional vector
 * @param nDvec		linear form of the n-dimensional vector to be constructed
 */
template <typename T>
nDvector<T>::nDvector (const std::vector<size_t> dim, const std::vector<T> nDvec)
{
	m_dimensions = dim;
	m_size = std::accumulate (dim.begin(), dim.end(), 1, std::multiplies<int>());
	
	assert(m_size != 0);
	assert(m_size == nDvec.size());
	m_nDvector_linear = std::vector<T>(nDvec.begin(), nDvec.end());
}

/*!
 * @return Sum of all elements of a n-dimensional vector
 */
template <typename T>
T
nDvector<T>::sum()
{
	return VectOp::ElSum(m_nDvector_linear);
}

/*!
 * @return vector with the dimensions of a n-dimensional vector
 */
template <typename T>
std::vector<size_t>
nDvector<T>::get_dimension() const
{
	return m_dimensions;
}

/*!
 * @return vector with linear form of a n-dimensional vector
 */
template <typename T>
std::vector<T>
nDvector<T>::get_linear_form() const
{
	return m_nDvector_linear;
}

/*!
 * @return size of the linear form of a n-dimensional vector (equivalent to product of all dimensions)
 */
template <typename T>
size_t
nDvector<T>::size() const
{
	return m_nDvector_linear.size();
}

/*!
 * get smaller nDvector from a bigget nDvector.
 * @param position		Vector with the n-dimensional index of the sub nDvector. Use full dimension value as MATLAB :
 * @discussion Remark: Since nDvectors have zero-based numbering, so full-dimension is NOT a valid position. That is why it can be used here as :
 */
// FIXIT: make the same using variadic templates - cleaner and much more beautiful
template <typename T>
nDvector<T>
nDvector<T>::get_subnDvector(const std::vector<size_t>& position) {

	
	std::vector<size_t> idx_0, idx_not0;
	std::vector<size_t> permuted_position;
	std::vector<size_t> new_dimension;
	std::vector<size_t> dim = m_dimensions;
	
	assert(dim.size() == position.size());
	
	for (size_t i = 0; i < position.size(); i++) {
		if (position[i] == dim[i]) {
			idx_0.push_back(i+1);
			new_dimension.push_back(dim[i]);
		} else {
			idx_not0.push_back(i+1);
			permuted_position.push_back(position[i]);
		}
	}
	
	std::vector<size_t> zeros(idx_0.size());
	permuted_position.insert(permuted_position.begin(), zeros.begin(), zeros.end());
	
// create order and permute to have fixed elements at the end
	std::vector<size_t> order = idx_0;
	order.insert( order.end(), idx_not0.begin(), idx_not0.end());
	
	nDvector<T> permuted_vector = permute(order);

	permuted_vector.print();
	
	size_t idx = permuted_vector.element_idx(permuted_position);
	
	
	size_t new_size = std::accumulate (new_dimension.begin(), new_dimension.end(), 1, std::multiplies<int>());
	std::vector<T> linear_form = permuted_vector.get_linear_form();
	std::vector<T> new_linear_form(linear_form.begin() + idx, linear_form.begin() + idx + new_size);
	
	nDvector<T> ret_vector(new_dimension, new_linear_form);
	
	return ret_vector;
}

/*!
 * get matrix from a nDvector
 * @param position_dimension_x	value representing the dimensions of the nDvector where the rows of the matrix are going to be taken
 * @param position_dimension_y	value representing the dimensions of the nDvector where the columns of the matrix are going to be taken
 * @position position			vector with position of the first matrix element
 */
template <typename T>
nDvector<T>
nDvector<T>::get_submatrix(const size_t position_dimension_x, const size_t position_dimension_y, const std::vector<size_t>& position) {
	
	assert(position[position_dimension_x - 1] == 0);
	assert(position[position_dimension_y - 1] == 0);
	
	std::vector<size_t> dim = m_dimensions;
	// easy case: pos_x = 1, pos_y = 2;
	if (position_dimension_x == 1 && position_dimension_y == 2) {
		size_t idx = element_idx(position);
		std::vector<T> linear_form = m_nDvector_linear;
		std::vector<T> matrix(linear_form.begin() + idx, linear_form.begin() + idx + dim[0]*dim[1]);
		std::vector<size_t> dim_matrix(dim.begin(), dim.begin()+1);
		nDvector<T> twoDvector(dim,matrix);
		return twoDvector;
	}
	
	// more difficult cases -> go to easy case
	std::vector<size_t> order = VectOp::Range((size_t) 1, (size_t)dim.size(), (size_t)1);
	std::swap(order[position_dimension_x - 1], order[0]);
	std::swap(order[position_dimension_y - 1], order[1]);
	
	std::vector<size_t> new_position(position.begin(), position.end());
	
	std::swap(new_position[position_dimension_x - 1], new_position[0]);
	std::swap(new_position[position_dimension_y - 1], new_position[1]);
	
	nDvector<T> permuted_vec = permute(order);
	
	return permuted_vec.get_submatrix(1, 2, new_position);
}

/*!
 * Sum all elements in a given dimension
 * @param dim	Dimensions to operate the sum
 * @return ret_nDvector		nDvector with the resultant sum. This vector has one dimension less than the previous one
 * @discussion Example: Suppose we have the matrix [1,2;3 4] and we sum on dim = 1, the result is [3;7]. If the sum is on dim = 2 the result is [4,6]
 */
template <typename T>
nDvector<T>
nDvector<T>::sum(size_t dim)
{
	dim = dim - 1;
	
	size_t jmp, shift, group, n_useless_groups;
	
	std::vector<size_t> new_dimension = m_dimensions;
	
	new_dimension.erase(new_dimension.begin() + dim);
	
	if (dim == 0) {
		jmp = 1;
	} else {
		jmp = std::accumulate (m_dimensions.begin(), m_dimensions.begin() + dim, 1, std::multiplies<int>());
	}
	
	shift = m_dimensions[dim] - 1;
	group = jmp*shift;
	
	std::vector<T> rotated_vec(m_nDvector_linear.begin(), m_nDvector_linear.end());
	std::vector<T> return_vec(m_nDvector_linear.begin(), m_nDvector_linear.end());
	
	if (dim + 2 > m_dimensions.size()){
		n_useless_groups = 1;
	} else if (dim + 2  == m_dimensions.size()) {
		n_useless_groups = m_dimensions.back();
	} else {
		n_useless_groups = std::accumulate(m_dimensions.begin() + dim + 1, m_dimensions.end(), 1, std::multiplies<int>());
	}
	
	for (size_t i = 0; i < shift; i++) {
		std::rotate(rotated_vec.begin(), rotated_vec.begin() + jmp, rotated_vec.end());
		return_vec = VectOp::Add(return_vec, rotated_vec);
	}
	
	for (size_t i = 1; i <= n_useless_groups; i++) {
		return_vec.erase(return_vec.begin() + i*jmp, return_vec.begin() + i*jmp + group);
	}
	
	nDvector<T> ret_nDvector(new_dimension, return_vec);
	
	return ret_nDvector;
}

/*!
 * @return mean of all elements
 */
template <typename T>
float
nDvector<T>::mean()
{
	nDvector<T> aux_nDvec(m_dimensions, m_nDvector_linear);
	return (float) aux_nDvec.sum()/m_size;
}

/*!
 * Mean of all elements in a given dimension
 * @param dim	Dimensions to operate the sum
 * @return aux_nDvector		nDvector with the resultant mean. This vector has one dimension less than the previous one
 * @discussion Example: Suppose we have the matrix [1,2;3 4] and we sum on dim = 1, the result is [1.5;3.5]. If the sum is on dim = 2 the result is [2,3]
 */
template <typename T>
nDvector<float>
nDvector<T>::mean(size_t dim)
{
	nDvector<float> aux_nDvec(m_dimensions, m_nDvector_linear);
	
	aux_nDvec = aux_nDvec.sum(dim);
	aux_nDvec.m_nDvector_linear = VectOp::Div(aux_nDvec.m_nDvector_linear, m_dimensions[dim-1]);
	
	return aux_nDvec;
}

/*!
 * Reshape n-dimensional vector with new dimensions. Size (dimensions product) should not change.
 * @paramenter new_dimension	vector with new dimension
 * @return reshaped_vec			reshaped n-dimensional vector
 */
template <typename T>
nDvector<T>
nDvector<T>::reshape(std::vector<size_t> new_dimension)
{
	
	nDvector<T> reshaped_vec(new_dimension);
	size_t size = 	std::accumulate (new_dimension.begin(), new_dimension.end(), 1, std::multiplies<int>());
	
	if (size != m_size) {
		fprintf(stderr, "To reshape the number of elements must not change.\n");
		assert(size == m_size);
	} else {
		reshaped_vec.m_nDvector_linear = m_nDvector_linear;
		return reshaped_vec;
	}
	
	return nDvector<T>();
}

/*!
 * Rearranges the dimensions of a nDvector so that they are in the order specified by the vector 'order'
 * @param order			order to rearrange nDvector
 * @return return_vec	permute nDvector
 */
// FIXME: nasty implementation...........
template <typename T>
nDvector<T>
nDvector<T>::permute(std::vector<size_t> order)
{
	if (order.size() == 2) {
		return permute2D(order);
	}
	
	std::vector<size_t> old_dimension = m_dimensions;
	assert(old_dimension.size() == order.size());
	
	std::vector<size_t> new_dimension, extended_idx(old_dimension.size(),0);
	
	for (size_t i = 0; i < order.size(); i++) {
		new_dimension.push_back(old_dimension[order[i] -1]);
	}
	
	std::vector<std::vector<size_t> > combination = combinations(m_size, old_dimension);
	std::vector<std::vector<size_t> > new_combination = perm_rows(combination, order);
	
	nDvector<T> return_vec(new_dimension,0);
	
	std::vector<std::vector<size_t> > combinationT = VectOp::transpose(combination);
	std::vector<std::vector<size_t> > new_combinationT = VectOp::transpose(new_combination);
	
	std::vector<T> aux_vector(m_size);
	for (size_t i = 0; i < combinationT.size(); i++) {
		aux_vector[return_vec.element_idx(new_combinationT[i])] = m_nDvector_linear[element_idx(combinationT[i])];
	}
	
	return_vec.vector_fill(aux_vector);
	
	return return_vec;
}

// FIXME: need to implement
template <typename T>
nDvector<T>
nDvector<T>::inverse_permute(std::vector<size_t> order)
{
	assert(0);
	return nDvector<T>();
}

// Permutation is so simple for 2D vectors.......
template <typename T>
nDvector<T>
nDvector<T>::permute2D(std::vector<size_t> order)
{
	std::vector<size_t> old_dimension = m_dimensions;
	std::vector<size_t> new_dimension(old_dimension.rbegin(), old_dimension.rend());
	
	assert(order.size() == old_dimension.size());
	assert(order.size() == 2);
	
	size_t last_idx = m_size - 1;
	
	std::vector<T> old_vector = m_nDvector_linear;
	std::vector<T> new_vector(m_size);
	
	if (order[0] == 1) {
		return *this;
	} else {
		
		for (size_t i = 0; i < last_idx; i++) {
			size_t new_idx = old_dimension[order[0]-1]*i % last_idx;
			new_vector[new_idx] = old_vector[i];
		}
		
		new_vector[last_idx] = old_vector[last_idx];
		
		nDvector<T> ret_vector(new_dimension, new_vector);
		return ret_vector;
	}
	
	return nDvector<T> ();
}

// Permutation is so simple for 2D vectors.......
template <typename T>
nDvector<T>
nDvector<T>::transpose()
{
	std::vector<size_t> order(2,0); order[0] = 2; order[1] = 1;
	return permute2D(order);
}

// Permutation is so simple for 2D vectors.......
template <typename T>
nDvector<T>
nDvector<T>::permute2D()
{
	return transpose();
}

/*
 * Similar to MATLAB repmat
 */
// FIXME: need further comments
template <typename T>
nDvector<T>
nDvector<T>::repeat(size_t repeat, size_t dimension)
{
	assert(repeat != 1);
	assert(!(dimension > m_dimensions.size() + 1));

	std::vector<T> aux_vector(m_nDvector_linear.begin(),m_nDvector_linear.end());

	while (aux_vector.size() < m_size*repeat) {
		aux_vector.insert(aux_vector.end(), aux_vector.begin(), aux_vector.end());
	}
	
	aux_vector.resize(m_size*repeat);

	std::vector<size_t> new_dimensions = m_dimensions;
	
	new_dimensions.push_back(repeat);
	
	nDvector<T> repeated_vector(new_dimensions,aux_vector);

	if (dimension == m_dimensions.size() + 1) {
		return repeated_vector;
	}
	std::vector<size_t> order = VectOp::Range((size_t) 1, (size_t)new_dimensions.size(), (size_t)1);
//	std::swap(order[dimension - 1], order[order.size() - 1]);
	order.insert(order.begin()+dimension, order[order.size()-1]);
	order.pop_back();
//	std::swap(order[0],order[1]);
	
	new_dimensions[dimension-1] *= repeat;
	new_dimensions.pop_back();

	nDvector<T> return_vector = repeated_vector.permute(order).reshape(new_dimensions);

	return return_vector;
}

template <typename T>
void
nDvector<T>::vector_fill(std::vector<T> vector)
{
	assert(!m_dimensions.empty());
	assert(m_size == vector.size());
	
	m_nDvector_linear = vector;
}

// FIXME: overload with variadic templates
// !!!: relatively easy to optimize - don't neet to put element by element - once permute is done I can just put the matrix in the first 2 dimensions (copying a vector, everything is linear here) and permute to put it to the right position.
template <typename T>
void
nDvector<T>::matrix_fill(const nDvector<T> matrix, const size_t position_dimension_rows, const size_t position_dimension_cols, const std::vector<size_t>& position)
{
	std::vector<size_t> dim = matrix.get_dimension();
	assert(dim.size() == 2);
	size_t rows = dim[0], cols = dim[1];
	
	if (rows > m_dimensions[position_dimension_rows - 1]) {
		rows = m_dimensions[position_dimension_rows - 1];
	}
	
	if (cols > m_dimensions[position_dimension_cols - 1]) {
		cols = m_dimensions[position_dimension_cols - 1];
	}
	
	size_t idx = 0;
	
	std::vector<size_t> position_it(position.begin(), position.end());
	assert(position.size() == m_dimensions.size());
	
	//	nDvector<T> dummy_vec(m_dimensions, m_nDvector_linear);
	
	std::vector<float> matrix_linear = matrix.get_linear_form();
	for (size_t i = 0; i < rows; i++) {
		for (size_t j = 0; j < cols; j++) {
			position_it[position_dimension_rows - 1] = i;
			position_it[position_dimension_cols - 1] = j;
			idx = nDvector<T>::element_idx(position_it);
			m_nDvector_linear[idx] = matrix_linear[rows*j + i];
		}
	}
}

// FIXME: overload with variadic templates
// !!!: relatively easy to optimize - don't neet to put element by element - once permute is done I can just put the matrix in the first 2 dimensions (copying a vector, everything is linear here) and permute to put it to the right position.
template <typename T>
void
nDvector<T>::matrix_fill(const std::vector<std::vector<T> > matrix, const size_t position_dimension_rows, const size_t position_dimension_cols, const std::vector<size_t>& position)
{
	size_t rows = matrix.size(), cols = matrix[0].size();
	
	if (rows > m_dimensions[position_dimension_rows - 1]) {
		rows = m_dimensions[position_dimension_rows - 1];
	}
	
	if (cols > m_dimensions[position_dimension_cols - 1]) {
		cols = m_dimensions[position_dimension_cols - 1];
	}
	
	size_t idx = 0;
	
	std::vector<size_t> position_it(position.begin(), position.end());
	assert(position.size() == m_dimensions.size());
	
	//	nDvector<T> dummy_vec(m_dimensions, m_nDvector_linear);
	
	for (size_t i = 0; i < rows; i++) {
		for (size_t j = 0; j < cols; j++) {
			position_it[position_dimension_rows - 1] = i;
			position_it[position_dimension_cols - 1] = j;
			idx = nDvector<T>::element_idx(position_it);
			m_nDvector_linear[idx] = matrix[i][j];
		}
	}
}

// FIXIT: ugly...
template <typename T>
void
nDvector<T>::matrix_fill(const std::vector<std::vector<T> > matrix)
{
	assert(m_dimensions.size() == 2);

	
	size_t rows = matrix.size(), cols = matrix[0].size(), idx;

	assert(rows <= m_dimensions[0]);
	assert(cols <= m_dimensions[1]);
	
	std::vector<size_t> position_it(2);
	
	for (size_t i = 0; i < rows; i++) {
		for (size_t j = 0; j < cols; j++) {
			position_it[0] = i;
			position_it[1] = j;
			idx = nDvector<T>::element_idx(position_it);
			m_nDvector_linear[idx] = matrix[i][j];
		}
	}
}

// FIXIT: yet to be implemented...
template <typename T>
nDvector<T>
nDvector<T>::nDvector_fill(const std::vector<size_t>& position) {
	assert(0);
	return nDvector<T>();
}

template <typename T>
nDvector<T>
const operator+(const nDvector<T>&lhs, const nDvector<T>& rhs)
{
	assert(lhs.get_dimension().size() == rhs.get_dimension().size());
	
	std::vector<T> sum_vec = VectOp::Sum(lhs.get_linear_form(), rhs.get_linear_form());
	
	nDvector<T> retvec(rhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const nDvector<T> &lhs, const int& factor)
{
	
	std::vector<T> sum_vec = VectOp::Sum(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const nDvector<T> &lhs, const float& factor)
{
	
	std::vector<T> sum_vec = VectOp::Sum(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const nDvector<T> &lhs, const double& factor)
{
	
	std::vector<T> sum_vec = VectOp::Sum(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const int& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sum_vec = VectOp::Sum(rhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(rhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const float& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sum_vec = VectOp::Sum(rhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(rhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator+(const double& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sum_vec = VectOp::Sum(rhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(rhs.get_dimension(), sum_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const nDvector<T>&lhs, const nDvector<T>& rhs)
{
	assert(lhs.get_dimension().size() == rhs.get_dimension().size());
	
	std::vector<T> sub_vec = VectOp::Sub(lhs.get_linear_form(), rhs.get_linear_form());
	
	nDvector<T> retvec(rhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const nDvector<T> &lhs, const int& factor)
{
	
	std::vector<T> sub_vec = VectOp::Sub(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const nDvector<T> &lhs, const float& factor)
{
	
	std::vector<T> sub_vec = VectOp::Sub(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const nDvector<T> &lhs, const double& factor)
{
	
	std::vector<T> sub_vec = VectOp::Sub(lhs.get_linear_form(), (T)factor);
	
	nDvector<T> retvec(lhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const int& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sub_vec = VectOp::Mul(VectOp::Sub(rhs.get_linear_form(), (T)factor),(T)-1);
	
	nDvector<T> retvec(rhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const float& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sub_vec = VectOp::Mul(VectOp::Sub(rhs.get_linear_form(), (T)factor),(T)-1);
	
	nDvector<T> retvec(rhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const double& factor, const nDvector<T> &rhs)
{
	
	std::vector<T> sub_vec = VectOp::Mul(VectOp::Sub(rhs.get_linear_form(), (T)factor),(T)-1);
	
	nDvector<T> retvec(rhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T>
nDvector<T>
const operator-(const nDvector<T> &rhs)
{
	
	std::vector<T> sub_vec = VectOp::Mul(rhs.get_linear_form(),(T)-1);
	
	nDvector<T> retvec(rhs.get_dimension(), sub_vec);
	
	return retvec;
}

template <typename T, typename P>
nDvector<T>
const operator/(const nDvector<T>& lhs, const P& factor)
{
	std::vector<T> div_vec = VectOp::Div(lhs.get_linear_form(), factor);
	
	nDvector<T> retvec(lhs.get_dimension(), div_vec);
	
	return retvec;
}

template <typename T, typename P>
nDvector<T>
const operator*(const nDvector<T>& lhs, const P &factor)
{
	std::vector<T> mul_vec = VectOp::Mul(lhs.get_linear_form(), factor);
	
	nDvector<T> retvec(lhs.get_dimension(), mul_vec);
	
	return retvec;
}

template <typename T, typename P>
nDvector<T>
const operator*(const P& factor, const nDvector<T>& rhs)
{
	std::vector<T> mul_vec = VectOp::Mul(rhs.get_linear_form(), factor);
	
	nDvector<T> retvec(rhs.get_dimension(), mul_vec);
	
	return retvec;
}



#endif /* defined(__VectorUtils__nDvectors2__) */
