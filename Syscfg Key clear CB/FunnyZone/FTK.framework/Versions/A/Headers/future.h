/*
 * Copyright 2009, Apple Inc.
 */

#include <stdio.h>
#include <pthread.h>
#include <FTK/sptr.h>
#include <unistd.h>


/*
 * A promise to provide a value in the future
 */
template <typename T>
struct promise
{
	promise()
	: m_data(new promised_data)
	{
	}


	/* promises behave like pointers */
	T const * operator -> () const
	{
		if (m_data.IsValid()) {
			m_data->wait_ready();
			return &m_data->m_data;
		} else {
			return 0;
		}
	}

	T const & operator *  () const
	{
		if (m_data.IsValid()) {
		} else {
			/*
			 * it should be impossible for m_data not to be valid,
			 * and if tht is the case we are going to die, so
			 * lets die
			 */
		}

		m_data->wait_ready();
		return m_data->m_data;
	}

	/* should never be false, if it ever is false... your memory is pretty corrupted */
	bool IsValid() const
	{
		return m_data.IsValid();
	}

	/* true if the prmise have been fulfilled */
	bool IsReady() const
	{
		return m_data.IsValid() && m_data->is_ready();
	}

	void fulfill(T const &result)
	{
		m_data->m_data = result;
		m_data->m_ready = true;
		pthread_mutex_lock(&m_data->m_mutex);
			pthread_cond_broadcast(&m_data->m_cond);
		pthread_mutex_unlock(&m_data->m_mutex);
	}

private:
	struct promised_data : public virtual ref_counted_t
	{
		T              m_data;
		bool           m_ready;

		pthread_cond_t  mutable m_cond;
		pthread_mutex_t mutable m_mutex;

		promised_data()
		: m_ready(false)
		{
			pthread_condattr_t cond_attr;
			pthread_mutexattr_t mutex_attr;

			pthread_condattr_init(&cond_attr);
			pthread_mutexattr_init(&mutex_attr);

			pthread_cond_init(&m_cond, &cond_attr);
			pthread_mutex_init(&m_mutex, &mutex_attr);
		}

		~promised_data()
		{
			pthread_cond_destroy(&m_cond);
			pthread_mutex_destroy(&m_mutex);
		}

		bool is_ready() const
		{
			return m_ready;
		}

		void wait_ready() const
		{
			if (m_ready) return;

			pthread_mutex_lock(&m_mutex);
			while (!m_ready) {
				pthread_cond_wait(&m_cond, &m_mutex);
			}
			pthread_mutex_unlock(&m_mutex);
		}
	};

	sptr_t<promised_data> m_data;


	template
	<
		typename Tr, typename Tf
	>
	friend class future_invocation;
};


/*
 * implementation detail, represents a delayed invocation
 */
namespace {
	template
	<
		typename Tr,
		typename Tf
	>
	struct
	future_invocation
	{
		future_invocation(Tf f)
		: m_f(f)
		{
		}
		virtual ~future_invocation()
		{
		}

		static void *trampoline(void *a)
		{
			future_invocation *self = static_cast<future_invocation *>(a);

			self->m_r.fulfill(self->invoke());

			return 0;
		}

		static promise<Tr> dispatch(future_invocation *i)
		{
			pthread_t thr;
			pthread_attr_t attr;

			pthread_attr_init(&attr);
			pthread_attr_setscope(&attr, PTHREAD_SCOPE_SYSTEM);

			pthread_create(&thr, &attr, trampoline, i);
			pthread_detach(thr);

			return i->m_r;
		}

		virtual Tr invoke() = 0;

		Tf          m_f;
		promise<Tr> m_r;
	};


	template
	<
		typename Tr, typename Tf
	>
	struct
	future_invocation_0: public future_invocation<Tr, Tf>
	{
		future_invocation_0(Tf f)
		: future_invocation<Tr, Tf>(f)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f();
		}
	};


	template
	<
		typename Tr, typename Tf,
		typename T1
	>
	struct
	future_invocation_1: public future_invocation<Tr, Tf>
	{
		future_invocation_1(Tf f, T1 const &a1)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(m_a1);
		}

		T1 m_a1;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2
	>
	struct
	future_invocation_2: public future_invocation<Tr, Tf>
	{
		future_invocation_2(Tf f, T1 const &a1, T2 const &a2)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2);
		}

		T1 m_a1;
		T2 m_a2;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3
	>
	struct
	future_invocation_3: public future_invocation<Tr, Tf>
	{
		future_invocation_3(Tf f, T1 const &a1, T2 const &a2, T3 const &a3)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4
	>
	struct
	future_invocation_4: public future_invocation<Tr, Tf>
	{
		future_invocation_4(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5
	>
	struct
	future_invocation_5: public future_invocation<Tr, Tf>
	{
		future_invocation_5(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6
	>
	struct
	future_invocation_6: public future_invocation<Tr, Tf>
	{
		future_invocation_6(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7
	>
	struct
	future_invocation_7: public future_invocation<Tr, Tf>
	{
		future_invocation_7(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7, typename T8
	>
	struct
	future_invocation_8: public future_invocation<Tr, Tf>
	{
		future_invocation_8(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7, T8 const &a8)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		, m_a8(a8)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7, this->m_a8);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
		T8 m_a8;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7, typename T8, typename T9
	>
	struct
	future_invocation_9: public future_invocation<Tr, Tf>
	{
		future_invocation_9(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7, T8 const &a8, T9 const &a9)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		, m_a8(a8)
		, m_a9(a9)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7, this->m_a8, this->m_a9);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
		T8 m_a8;
		T9 m_a9;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7, typename T8, typename T9,
		typename T10
	>
	struct
	future_invocation_10: public future_invocation<Tr, Tf>
	{
		future_invocation_10(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7, T8 const &a8, T9 const &a9, T10 const &a10)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		, m_a8(a8)
		, m_a9(a9)
		, m_a10(a10)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7, this->m_a8, this->m_a9, this->m_a10);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
		T8 m_a8;
		T9 m_a9;
		T10 m_a10;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7, typename T8, typename T9,
		typename T10, typename T11
	>
	struct
	future_invocation_11: public future_invocation<Tr, Tf>
	{
		future_invocation_11(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7, T8 const &a8, T9 const &a9, T10 const &a10, T11 const &a11)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		, m_a8(a8)
		, m_a9(a9)
		, m_a10(a10)
		, m_a11(a11)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7, this->m_a8, this->m_a9, this->m_a10, this->m_a11);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
		T8 m_a8;
		T9 m_a9;
		T10 m_a10;
		T11 m_a11;
	};


	template
	<
		typename Tr, typename Tf,
		typename T1, typename T2, typename T3,
		typename T4, typename T5, typename T6,
		typename T7, typename T8, typename T9,
		typename T10, typename T11, typename T12
	>
	struct
	future_invocation_12: public future_invocation<Tr, Tf>
	{
		future_invocation_12(Tf f, T1 const &a1, T2 const &a2, T3 const &a3, T4 const &a4, T5 const &a5, T6 const &a6, T7 const &a7, T8 const &a8, T9 const &a9, T10 const &a10, T11 const &a11, T12 const &a12)
		: future_invocation<Tr, Tf>(f)
		, m_a1(a1)
		, m_a2(a2)
		, m_a3(a3)
		, m_a4(a4)
		, m_a5(a5)
		, m_a6(a6)
		, m_a7(a7)
		, m_a8(a8)
		, m_a9(a9)
		, m_a10(a10)
		, m_a11(a11)
		, m_a12(a12)
		{
			/* nop */
		}

		virtual Tr invoke()
		{
			return this->m_f(this->m_a1, this->m_a2, this->m_a3, this->m_a4, this->m_a5, this->m_a6, this->m_a7, this->m_a8, this->m_a9, this->m_a10, this->m_a11, this->m_a12);
		}

		T1 m_a1;
		T2 m_a2;
		T3 m_a3;
		T4 m_a4;
		T5 m_a5;
		T6 m_a6;
		T7 m_a7;
		T8 m_a8;
		T9 m_a9;
		T10 m_a10;
		T11 m_a11;
		T11 m_a12;
	};
}


/*
 * futures from 0 to 12 arguments
 */
template
<
	typename Tr, typename Tf
>
promise<Tr>
future(Tf f)
{
	typedef Tr(*fun)();
	typedef future_invocation<Tr, Tf> future;

	future *args = new future;

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1
>
promise<Tr>
future
(
	Tf f,
	T1 a1
)
{
	typedef Tr(*fun)(T1);
	typedef future_invocation_1<Tr, Tf, T1> future;

	future *args = new future(f, a1);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2
)
{
	typedef Tr(*fun)(T1, T2);
	typedef future_invocation_2<Tr, Tf, T1, T2> future;

	future *args = new future(f, a1, a2);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3
>
promise<Tr>
future
(
	Tf f,
	T1 const &a1,
	T2 const &a2,
	T3 const &a3
)
{
	typedef Tr(*fun)(T1, T2, T3);
	typedef future_invocation_3<Tr, Tf, T1, T2, T3> future;

	future *args = new future(f, a1, a2, a3);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4
)
{
	typedef Tr(*fun)(T1, T2, T3, T4);
	typedef future_invocation_4<Tr, Tf, T1, T2, T3, T4> future;

	future *args = new future(f, a1, a2, a3, a4);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5);
	typedef future_invocation_5<Tr, Tf, T1, T2, T3, T4, T5> future;

	future *args = new future(f, a1, a2, a3, a4, a5);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6);
	typedef future_invocation_6<Tr, Tf, T1, T2, T3, T4, T5, T6> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7);
	typedef future_invocation_7<Tr, Tf, T1, T2, T3, T4, T5, T6, T7> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7, typename T8
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7,
	T8 a8
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7, T8);
	typedef future_invocation_8<Tr, Tf, T1, T2, T3, T4, T5, T6, T7, T8> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7, a8);

	return future::dispatch(args);
}


template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7, typename T8, typename T9
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7,
	T8 a8,
	T9 a9
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7, T8, T9);
	typedef future_invocation_9<Tr, Tf, T1, T2, T3, T4, T5, T6, T7, T8, T9> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7, a8, a9);

	return future::dispatch(args);
}

template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7, typename T8, typename T9,
	typename T10
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7,
	T8 a8,
	T9 a9,
	T10 a10
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10);
	typedef future_invocation_10<Tr, Tf, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);

	return future::dispatch(args);
}

template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7, typename T8, typename T9,
	typename T10, typename T11
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7,
	T8 a8,
	T9 a9,
	T10 a10,
	T11 a11
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11);
	typedef future_invocation_11<Tr, Tf, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11);

	return future::dispatch(args);
}

template
<
	typename Tr, typename Tf,
	typename T1, typename T2, typename T3,
	typename T4, typename T5, typename T6,
	typename T7, typename T8, typename T9,
	typename T10, typename T11, typename T12
>
promise<Tr>
future
(
	Tf f,
	T1 a1,
	T2 a2,
	T3 a3,
	T4 a4,
	T5 a5,
	T6 a6,
	T7 a7,
	T8 a8,
	T9 a9,
	T10 a10,
	T11 a11,
	T12 a12
)
{
	typedef Tr(*fun)(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12);
	typedef future_invocation_12<Tr, Tf, T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12> future;

	future *args = new future(f, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12);

	return future::dispatch(args);
}


/* vim: se ts=8 sw=8 ai nowrap number incsearch hlsearch :miv */
