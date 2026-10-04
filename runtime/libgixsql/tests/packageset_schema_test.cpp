// The CURRENT PACKAGESET -> CURRENT SCHEMA emulation (utils.cpp packageset_as_schema).
//   g++ -std=c++17 -I runtime/libgixsql runtime/libgixsql/tests/packageset_schema_test.cpp \
//       runtime/libgixsql/.libs/libgixsql_la-utils.o -lspdlog -lfmt -o /tmp/pst && /tmp/pst
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <string>
#include "utils.h"

int main()
{
	std::string out, value = "COLL01  ";
	unsetenv("GIXSQL_PACKAGESET_SCHEMAS");
	assert(!packageset_as_schema("Set Current Packageset = ?", &value, out));

	setenv("GIXSQL_PACKAGESET_SCHEMAS", "COLL01=SCHEMA1, coll02=schema2", 1);
	assert(packageset_as_schema("Set Current Packageset = ?", &value, out));
	assert(out == "SET CURRENT SCHEMA = 'SCHEMA1'");
	value = "coll02";
	assert(packageset_as_schema("SET CURRENT PACKAGESET = ?", &value, out));
	assert(out == "SET CURRENT SCHEMA = 'SCHEMA2'");
	assert(packageset_as_schema("SET CURRENT PACKAGESET = 'COLL01'", NULL, out));
	assert(out == "SET CURRENT SCHEMA = 'SCHEMA1'");

	unsetenv("GIXSQL_DEFAULT_SCHEMA");
	assert(!packageset_as_schema("Set Current Packageset = ''", NULL, out));
	setenv("GIXSQL_DEFAULT_SCHEMA", "HOME", 1);
	assert(packageset_as_schema("Set Current Packageset = ''", NULL, out));
	assert(out == "SET CURRENT SCHEMA = 'HOME'");

	value = "OTHER";
	assert(!packageset_as_schema("Set Current Packageset = ?", &value, out));
	assert(!packageset_as_schema("SELECT 1 FROM SYSIBM.SYSDUMMY1", NULL, out));
	puts("packageset_schema_test: ok");
	return 0;
}
