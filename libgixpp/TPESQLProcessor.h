/*
This file is part of Gix-IDE, an IDE and platform for GnuCOBOL
Copyright (C) 2021 Marco Ridoni

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA.
*/

#pragma once

#include <string>
#include <vector>
#include <map>
#include <stack>
#include <memory>

#include "ITransformationStep.h"
#include "ESQLDefinitions.h"
#include "gix_esql_driver.hh"
#include "ESQLCall.h"

class gix_esql_driver;
struct esql_whenever_clause_handler_t;

enum class ESQL_Command;

class TPESQLProcessor : public ITransformationStep
{
	friend class gix_esql_driver;

public:
	TPESQLProcessor(GixPreProcessor *gpp);

	std::string getModuleName();

	std::map<std::string, std::string> &getSrcLineMap() const;
	std::map<std::string, std::string> &getSrcLineMapReverse() const;

	std::map<uint64_t, uint64_t> &getBinarySrcLineMap() const;
	std::map<uint64_t, uint64_t> &getBinarySrcLineMapReverse() const;

	std::map<std::string, int> &getFileMap() const;
	std::map<int, std::string> getReverseFileMap();
	std::map<std::string, cb_field_ptr> &getVariableDeclarationInfoMap() const;

	std::map<std::string, srcLocation> getParagraphs();
	std::map<std::string,  std::vector<std::string>> getFileDependencies();

	// Inherited via ITransformationStep
	virtual bool run(std::shared_ptr<ITransformationStep> prev_step) override;
	TransformationStepDataType getInputType() override;
	TransformationStepDataType getOutputType() override;
	virtual TransformationStepData* getOutput(std::shared_ptr<ITransformationStep> me = nullptr) override;


private:

	std::string current_file;

	std::string input_file;
	std::string output_file;

	std::vector<std::string> output_lines;

	int output_line;

	std::map<std::string, std::string> in_to_out;
	std::map<std::string, std::string> out_to_in;

	std::map<uint64_t, uint64_t> b_in_to_out;
	std::map<uint64_t, uint64_t> b_out_to_in;

	//std::vector<PreprocessedBlockInfo*> preprocessed_blocks;
	std::map<cb_exec_sql_stmt_ptr, std::tuple<int, int>> generated_blocks;

	int outputESQL();
	cb_exec_sql_stmt_ptr find_exec_sql_stmt(const std::string filename, int i);
	cb_exec_sql_stmt_ptr find_esql_cmd(std::string cmd, int idx);
	std::string comment_line(const std::string &comment, const std::string &line);

	void put_output_line(const std::string &line);
	bool handle_esql_stmt(const ESQL_Command cmd, const cb_exec_sql_stmt_ptr stmt, bool is_in_ws);

	bool find_working_storage(int *working_begin_line, int *working_end_line);
	bool find_linkage_section(int* linkage_begin_line, int* linkage_end_line);

	bool processNextFile();

	std::string get_call_id(const std::string s);

	void put_start_exec_sql(bool with_period);
	void put_end_exec_sql(bool with_period);
	bool put_query_defs();
	void put_working_storage();
	bool put_cursor_declarations();
	bool put_call(const ESQLCall &call, bool terminate_with_period, int indent_level = 0);

	//bool is_var_len_group(cb_field_ptr f);
	//bool get_actual_field_data(cb_field_ptr f, CobolVarType* type, int *size, int *scale);
	void process_sql_query_list();
	std::string process_sql_query_item(const std::vector<std::string>& input_sql_list);
	bool fixup_declared_vars();

	bool write_map_file(const std::string &preprocd_file);
	bool build_map_data();

	void map_collect_files(std::map<std::string, int> &filemap);

	void splitLineEntry(const std::string &k, std::string &s, int *i);

	bool generate_consolidated_map();

	void add_dependency(const std::string &parent, const std::string &dep_path);

	bool is_current_file_included();

	void put_whenever_handler(bool terminate_with_period);
	void put_whenever_clause_handler(esql_whenever_clause_handler_t* ch);
	void put_smart_cursor_init_flags();
	void put_smart_cursor_init_check(const std::string& crsr_name, bool reset_sqlcode = false);

	bool put_res_host_parameters(const cb_exec_sql_stmt_ptr stmt, int *res_params_count);
	bool put_host_parameters(const cb_exec_sql_stmt_ptr stmt);

	// Flatten a group host variable into its elementary leaf fields, in
	// declaration order, descending through nested (non-varlen) subgroups.
	void collect_group_leaves(cb_field_ptr f, std::vector<cb_field_ptr>& out);

	// Fully-qualified COBOL reference ("LEAF OF PARENT OF ... OF ROOT") so a
	// decomposed group leaf is unambiguous when the same name recurs elsewhere.
	std::string field_qualified_name(cb_field_ptr f);

	// A group host variable used with a null indicator pairs each decomposed
	// leaf with one element of an indicator ARRAY (DB2 semantics). Validate the
	// indicator exists and is an OCCURS table; returns it via *ind_field
	// (nullptr when has_indicator is false), or raises and returns false on a
	// missing indicator or a scalar (non-array) one.
	bool validate_group_indicator(bool has_indicator, const std::string& ind_name,
		const std::string& full_ref, const std::string& src, int lineno,
		cb_field_ptr* ind_field);

	// Append the trailing null-indicator argument for one decomposed group leaf
	// (1-based leaf_idx): the indicator-array element when leaf_idx is within the
	// array, otherwise the site's original null placeholder (BY VALUE 0 vs BY
	// REFERENCE 0). An indicator array smaller than the group is allowed (DB2
	// supplies indicators only for the leading columns); the rest get no indicator.
	void add_leaf_indicator(ESQLCall& call, bool has_indicator,
		cb_field_ptr ind_field, int leaf_idx, bool by_value_null);

	void add_preprocessed_blocks();
	bool decode_indicator(const std::string& orig_name, std::string& var_name, std::string& ind_name);

	std::stack<std::string> input_file_stack;

	int working_begin_line = 0;
	int working_end_line = 0;
	int linkage_begin_line = 0;
	int linkage_end_line = 0;
	
	std::string code_tag;

	std::vector<std::string> ws_query_list;
	std::vector<cb_exec_sql_stmt_ptr> startup_items;

	std::map<std::string, int> filemap;

	std::map<std::string,  std::vector<std::string>> file_dependencies;

	int current_input_line;

	bool emitted_query_defs = false;
	bool emitted_smart_cursor_init_flags = false;

	std::shared_ptr<ESQLParserData> parser_data;

	void raise_error(const std::string& m, int err_code, std::string filename = std::string(), int line = -1);

};

