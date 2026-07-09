#pragma once

#define GIXSQL_DEFAULT_NO_REC_CODE						100
#define GIXSQL_DEFAULT_VARYING_LEN_SZ_SHORT				false
#define GIXSQL_DEFAULT_VARLEN_BIGENDIAN					false

#include <string>

#ifndef LIBGIXSQL_API
#if defined(_WIN32) || defined(_WIN64)
#define LIBGIXSQL_API __declspec(dllexport)   
#else  
#define LIBGIXSQL_API
#endif
#endif

class LIBGIXSQL_API GlobalEnv
{
	friend int f_norec_sqlcode();
	friend int f_varlen_length_sz();
	friend std::string f_get_trimmed_hostref_or_literal(void* data, int l);
	friend bool f_varlen_length_sz_short();
	friend int f_varlen_get_len(void* addr);
	friend void f_varlen_set_len(void* addr, int len);

public:

	GlobalEnv();

	std::string (*get_trimmed_hostref_or_literal)(void* data, int l);
	int (*norec_sqlcode)();
	int (*varlen_length_sz)();
	bool (*varlen_length_sz_short)();

	// Read/write the length prefix of a VARYING host variable, honoring
	// GIXSQL_VARLEN_BIGENDIAN (COBOL compiled with big-endian BINARY fields,
	// e.g. GnuCOBOL -std=ibm, stores S9(4) COMP prefixes big-endian).
	int (*varlen_get_len)(void* addr);
	void (*varlen_set_len)(void* addr, int len);

private:

	int __norec_sqlcode = GIXSQL_DEFAULT_NO_REC_CODE;
	bool __varying_len_sz_short = GIXSQL_DEFAULT_VARYING_LEN_SZ_SHORT;
	bool __varlen_bigendian = GIXSQL_DEFAULT_VARLEN_BIGENDIAN;

	void setup_no_rec_code();
	void setup_varying_length_size();
	void setup_varlen_byteorder();


};


