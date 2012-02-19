#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%%{
	machine http_main;

	action field_name_start {
		//printf("field_name_start: '%s'\n", fpc);
		printf("field_name_start\n");
	}
	action field_name_end {
		//printf("field_name_end: '%s'\n", fpc);
		printf("field_name_end\n");
	}
	action field_value_start {
		//printf("field_value_start: '%s'\n", fpc);
		printf("field_value_start\n");
	}
	action field_value_end {
		//printf("field_value_end: '%s'\n", fpc);
		printf("field_value_end\n");
	}
	action field_name_char {
		printf("field_name: '%c'\n", fc);
	}
	action field_value_char {
		printf("field_value: '%c'\n", fc);
	}
	action headers_end {
		printf("headers_end\n");
		fbreak;
	}
	action scheme_start { }
	action scheme_end { }
	action authority_start { }
	action authority_end { }
	action abs_path_start { }
	action abs_path_end { }
	action query_start { }
	action query_end { }
	action fragment_start { }
	action fragment_end { }
	action request_uri_star { }
	action request_uri_authority { }
	action request_uri_relative { }
	action request_uri_absolute { }
	action request_end {
		printf("request_end\n");
		fbreak;
	}
	action response_end {
		printf("response_end\n");
		fbreak;
	}

	include http "http.rl";

	main := Message_Headers;
}%%

%% write data;

int test(const char* p, const char* pe)
{
	int cs;
	//const char* eof = pe - 3;
	%% write init;
	%% write exec;
	printf("leftover: '%s'\n", p);
	return cs >= http_main_first_final ? cs : -1;
}

int main(int argc, char** argv)
{
	const char* data =
		"Header: first value\r\n"
		"Header: second value\r\n"
		"Header: value \r\n"
		" continued\r\n"
		"Header: value  \r\n"
		" \r\n"
		"Header: \r\n"
		" \r\n"
		"Header:\r\n"
		"\r\n..///....";
	printf("%d\n", test(data, data + strlen(data)));
	return 0;
}
