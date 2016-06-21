/*
 *
 *	  Copyright (c) 2006 Apple Computer, Inc.
 *	  All rights reserved.
 *
 *	  This document is the property of Apple Computer, Inc. It is
 *	  considered confidential and proprietary information.
 *
 *	  This document may not be reproduced or transmitted in any form,
 *	  in whole or in part, without the express written permission of
 *	  Apple Computer, Inc.
 */

#ifndef eapps__sptr__hh__
#define eapps__sptr__hh__


#include <assert.h>


struct
ref_counted_t__
{
	ref_counted_t__(): m_refcnt(0) { }

	/* refcounts should be left alone when copying objects */
	ref_counted_t__(ref_counted_t__ const &): m_refcnt(0) { }

	ref_counted_t__ &operator =(ref_counted_t__ const &) { return *this; }

	int m_refcnt;
};

struct
ref_counted_t : public virtual ref_counted_t__
{
};

template <typename T>
struct sptr_t
{
	sptr_t();
	sptr_t(T *o);
	sptr_t(sptr_t const &o);

	~sptr_t();

	template <typename U> sptr_t(U *o);
	template <typename U> sptr_t(sptr_t<U> const &o);

	sptr_t const & operator = (T *o);
	sptr_t const & operator = (sptr_t const &o);
	template <typename U> sptr_t const &operator = (U *o);
	template <typename U> sptr_t const &operator = (sptr_t<U> const &o);

	T * operator -> () const;
	T & operator * () const;

	bool operator ==(T const *o) const;
	bool operator !=(T const *o) const;

	bool IsShared() const { return m_ptr->m_refcnt > 1; }

	/* these two are non kosher, use at your own peril... */
	bool IsValid() const { return m_ptr!= 0; }
	T const *Unbox() const { return m_ptr; }

	private:
		T *m_ptr;

		T *m_incref(T *t);
		void m_decref(T *t);

	template <typename U> friend class sptr_t;
};



template <typename T>
sptr_t<T>::sptr_t()
: m_ptr(0)
{
}

template <typename T>
sptr_t<T>::sptr_t(T *o)
: m_ptr(m_incref(o))
{
}

template <typename T>
sptr_t<T>::sptr_t(sptr_t const &o)
: m_ptr(m_incref(o.m_ptr))
{
}



template <typename T>
sptr_t<T>::~sptr_t()
{
	m_decref(m_ptr);
	m_ptr = 0;
}



template <typename T>
template <typename U>
sptr_t<T>::sptr_t(U *o)
: m_ptr(m_incref(static_cast<T*>(o)))
{
}

template <typename T>
template <typename U>
sptr_t<T>::sptr_t(sptr_t<U> const &o)
: m_ptr(m_incref(static_cast<T*>(o.m_ptr)))
{
}



template <typename T>
sptr_t<T> const &
sptr_t<T>::operator = (T *o)
{
	T *aux = m_ptr;

	if (aux != o) {
		m_ptr = m_incref(o);
		m_decref(aux);
	}

	return *this;
}

template <typename T>
sptr_t<T> const &
sptr_t<T>::operator = (sptr_t const &o)
{
	T *aux = m_ptr;

	m_ptr = m_incref(o.m_ptr);
	m_decref(aux);

	return *this;
}

template <typename T>
template <typename U>
sptr_t<T> const &
sptr_t<T>::operator = (U *o)
{
	T *aux = m_ptr;

	if (aux!= static_cast<T *> (o)) {
		m_ptr = m_incref(static_cast<T *> (o));
		m_decref(aux);
	}

	return *this;
}

template <typename T>
template <typename U>
sptr_t<T> const &
sptr_t<T>::operator = (sptr_t<U> const &o)
{
	T *aux = m_ptr;

	m_ptr = m_incref(static_cast<T*>(o.m_ptr));
	m_decref(aux);

	return *this;
}



template <typename T>
T *
sptr_t<T>::operator -> () const
{
	return m_ptr;
}

template <typename T>
T &
sptr_t<T>::operator * () const
{
	return *m_ptr;
}



template <typename T>
bool
sptr_t<T>::operator ==(T const *o) const
{
	return m_ptr == o;
}

template <typename T>
bool
sptr_t<T>::operator !=(T const *o) const
{
	return m_ptr != o;
}


#if defined(__APPLE__)
#include <libkern/OSAtomic.h>

static
inline
int
atomic_inc_32(int volatile *ptr)
{
	return OSAtomicIncrement32(ptr);
}

static
inline
int
atomic_dec_32(int volatile *ptr)
{
	return OSAtomicDecrement32(ptr);
}

#elif defined(__WIN32__)
#else

static
inline
int
atomic_inc_32(int volatile *ptr)
{
#warning sptr_t<> is not thread safe
	// XXX : mpetit : should use atomic ops
	*ptr += 1;

	return *ptr;
}

static
inline
int
atomic_dec_32(int volatile *ptr)
{
#warning sptr_t<> is not thread safe
	// XXX : mpetit : should use atomic ops
	*ptr -= 1;

	return *ptr;
}

#endif

template <typename T>
T *
sptr_t<T>::m_incref(T *t)
{
	if (t) {
		atomic_inc_32(&(t->m_refcnt));
	}

	return t;
}

template <typename T>
void
sptr_t<T>::m_decref(T *t)
{
	if (t) {
		assert(t->m_refcnt > 0);

		if (!atomic_dec_32(&(t->m_refcnt))) {
			delete t;
		}
	}
}


#endif

