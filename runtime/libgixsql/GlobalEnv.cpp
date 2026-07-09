#include "GlobalEnv.h"

#include <cstdint>
#include <cstring>

#include "Logger.h"
#include "utils.h"

std::string f_get_trimmed_hostref_or_literal(void* data, int l);
int f_norec_sqlcode();
int f_varlen_length_sz();
bool f_varlen_length_sz_short();
int f_varlen_get_len(void* addr);
void f_varlen_set_len(void* addr, int len);

static std::shared_ptr<GlobalEnv> genv;;

GlobalEnv::GlobalEnv()
{
	genv = std::shared_ptr<GlobalEnv>(this);

	setup_no_rec_code();
	setup_varying_length_size();
	setup_varlen_byteorder();

	get_trimmed_hostref_or_literal = f_get_trimmed_hostref_or_literal;
	norec_sqlcode = f_norec_sqlcode;
	varlen_length_sz = f_varlen_length_sz;
	varlen_length_sz_short = f_varlen_length_sz_short;
	varlen_get_len = f_varlen_get_len;
	varlen_set_len = f_varlen_set_len;
}

void GlobalEnv::setup_no_rec_code()
{
	char* c = getenv("GIXSQL_NOREC_CODE");
	if (c) {
		int i = atoi(c);
		if (i != 0 && i >= -999999999 && i <= 999999999) {
			__norec_sqlcode = i;
		}
	}
	spdlog::info("GixSQL: \"no record found\" code set to {})", __norec_sqlcode);
}

void GlobalEnv::setup_varying_length_size()
{
	char* c = getenv("GIXSQL_VARYING_LEN_SZ_SHORT");
	if (c) {
		int i = atoi(c);
		if (i == 1) {
			__varying_len_sz_short = true;
		}
	}

	spdlog::info("GixSQL: length indicator for VARYING fields set to {} ({} bits)", (__varying_len_sz_short ? 2 : 4), (__varying_len_sz_short ? 16 : 32));
}

void GlobalEnv::setup_varlen_byteorder()
{
	char* c = getenv("GIXSQL_VARLEN_BIGENDIAN");
	if (c && atoi(c) == 1) {
		__varlen_bigendian = true;
	}

	spdlog::info("GixSQL: length indicator for VARYING fields is {}-endian", (__varlen_bigendian ? "big" : "native"));
}

// The length prefix of a VARYING host var belongs to the COBOL program: with
// big-endian BINARY fields (GnuCOBOL -std=ibm) the program MOVEs the length
// as big-endian, so on a little-endian host it must be byte-swapped here.
int f_varlen_get_len(void* addr)
{
	if (genv->__varying_len_sz_short) {
		uint16_t v;
		memcpy(&v, addr, sizeof(v));
		if (genv->__varlen_bigendian)
			v = (uint16_t)((v >> 8) | (v << 8));
		return v;
	}
	uint32_t v;
	memcpy(&v, addr, sizeof(v));
	if (genv->__varlen_bigendian)
		v = ((v >> 24) & 0xffu) | ((v >> 8) & 0xff00u)
		  | ((v << 8) & 0xff0000u) | (v << 24);
	return (int)v;
}

void f_varlen_set_len(void* addr, int len)
{
	if (genv->__varying_len_sz_short) {
		uint16_t v = (uint16_t)len;
		if (genv->__varlen_bigendian)
			v = (uint16_t)((v >> 8) | (v << 8));
		memcpy(addr, &v, sizeof(v));
		return;
	}
	uint32_t v = (uint32_t)len;
	if (genv->__varlen_bigendian)
		v = ((v >> 24) & 0xffu) | ((v >> 8) & 0xff00u)
		  | ((v << 8) & 0xff0000u) | (v << 24);
	memcpy(addr, &v, sizeof(v));
}

int f_norec_sqlcode()
{
	return genv->__norec_sqlcode;
}

int f_varlen_length_sz()
{
	return genv->__varying_len_sz_short ? 2 : 4;
}


std::string f_get_trimmed_hostref_or_literal(void* data, int l)
{
	if (!data)
		return std::string();

	if (!l)
		return std::string((char*)data);

	if (l > 0) {
		std::string s = std::string((char*)data, l);
		return trim_copy(s);
	}

	// variable-length fields (negative length)
	int actual_len = 0;
	void* actual_data = (char*)data + genv->varlen_length_sz();
	if (genv->__varying_len_sz_short) {
		actual_len =  *((uint16_t*)data);
	}
	else {
		actual_len = *((uint32_t*)data);
	}

	// Should we check the actual length against the defined length?
	//...

	std::string t = std::string((char*)actual_data, (-l) - genv->varlen_length_sz());
	return trim_copy(t);
}

bool f_varlen_length_sz_short()
{
	return genv->__varying_len_sz_short;
}