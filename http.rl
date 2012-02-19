%%{
	machine http;

#
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec2.html#sec2.2
#
	OCTET = extend;
	CHAR = ascii;
	UPALPHA = upper;
	LOALPHA = lower;
	ALPHA = alpha;
	DIGIT = digit;
	HEX = xdigit;
	CTL = (cntrl | 127);
	HT = '\t';
	LF = '\n';
	CR = '\r';
	SP = ' ';
	CRLF = CR LF;
	LWS = CRLF? (SP | HT);
	TEXT = ((OCTET - CTL) | LWS)*;

	SEPARATOR = [()<>@,;:\\"/\[\]?={}] | SP | HT;
	TOKEN = (CHAR - (CTL | SEPARATOR))+;

	# Like TEXT, but non-empty and LWS trimmed
	TEXT_TRIMMED = (OCTET - CTL - LWS)+ (LWS+ (OCTET - CTL - LWS)+)*;

#
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
#
	field_name = TOKEN >field_name_start %field_name_end $field_name_char;
	field_content = TEXT_TRIMMED >field_value_start %field_value_end $field_value_char;
	field_value = LWS* field_content? LWS*;
	message_header = field_name ":" field_value;
	Headers = (message_header CRLF)*
	          CRLF []>~headers_end;

#
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.1
#
	HTTP_Version = "HTTP" "/" digit+ "." digit+;

#
# See http://www.ietf.org/rfc/rfc2396.txt
#

	extended      = extend - ascii;
	escaped       = "%" xdigit xdigit;
	mark          = [\-_.!~*'()];
	unreserved    = alnum | mark | extended;
	reserved      = [;/?:@&=+$,];
	uric          = reserved | unreserved | escaped;

	fragment      = uric* >fragment_start %fragment_end;

	query         = uric* >query_start %query_end;

	pchar         = unreserved | escaped | [:@&=+$,];
	param         = pchar*;
	segment       = pchar* (";" param)*;
	path_segments = segment ("/" segment)*;

	port          = digit*;
	IPv4address   = digit+ "." digit+ "." digit+ "." digit+;
	toplabel      = alpha ((alnum | "-")* alnum)?;
	domainlabel   = alnum ((alnum | "-")* alnum)?;
	hostname      = (domainlabel ".")* toplabel (".")?;
	host          = hostname | IPv4address;
	hostport      = host (":" port)?;

	userinfo      = (unreserved | escaped | [;:&=+$,])*;
	server        = (userinfo "@")? hostport;

	reg_name      = (unreserved | escaped | [$,;:@&=+])+;

	authority     = (server | reg_name) >authority_start %authority_end;

	scheme        = (alpha (alpha | digit | "+" | "-" | ".")*) >scheme_start %scheme_end;

	abs_path      = ("/" path_segments) >abs_path_start %abs_path_end;

	relativeURI   = (abs_path) ("?" query)?;
	absoluteURI   = (scheme "://" authority? abs_path?) ("?" query)?;

#
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec5.html#sec5
#

	Request_URI = ("*" %request_uri_star)
	            | (authority %request_uri_authority)
	            | (relativeURI %request_uri_relative)
	            | (absoluteURI %request_uri_absolute);

	Request_Method = "OPTIONS"
	               | "GET"
	               | "HEAD"
	               | "POST"
	               | "PUT"
	               | "DELETE"
	               | "TRACE"
	               | "CONNECT"
	               | TOKEN;

	Request_Line = Request_Method SP Request_URI SP HTTP_Version CRLF;

	Request = Request_Line
	          (message_header CRLF)*
	          CRLF []>~request_end;

#
# See http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6
#

	Reason_Phrase = (TEXT -- CR -- LF);
	Status_Code = digit digit digit;

	Status_Line = HTTP_Version SP Status_Code SP Reason_Phrase CRLF;

	Response = Status_Line
	           (message_header CRLF)*
	           CRLF []>~response_end;

}%%
