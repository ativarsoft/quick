with System;
use System;
with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;

package body Templatizer.HTTP is

   subtype http_cookie_callback_t is System.Address;
   subtype http_query_callback_t is System.Address;
   subtype tmpl_stream_t is System.Address;

   type Stream is new tmpl_stream_t;

   procedure Parse_Cookie_String
   is
      function Templatizer_Parse_Cookie_String
         (data : System.Address;
          cb : System.Address)
          return int;
      pragma Import
         (C, Templatizer_Parse_Cookie_String, "tmpl_parse_cookie_string");

      R : int;
   begin
      R := Templatizer_Parse_Cookie_String
         (System.Null_Address, System.Null_Address);

      if R /= 0 then
         raise Program_Error with "Error parsing cookie string.";
      end if;
   end Parse_Cookie_String;

   function Percent_Decoded_Len
      (Query : String)
      return Natural
   is
      function Templatizer_Percent_Decoded_Len
         (query    : chars_ptr;
          inputlen : size_t)
          return size_t;
      pragma Import
         (C, Templatizer_Percent_Decoded_Len, "tmpl_percent_decoded_len");

      Length : size_t;
      S : chars_ptr := New_String (Query);
   begin
      Length := Templatizer_Percent_Decoded_Len
         (S, Strlen (S));
      Free (S);
      return Natural (Length);
   end Percent_Decoded_Len;

   function Percent_Decode_File
      (Input, Output : Stream;
       X : out Natural)
       return Natural
   is
      function Templatizer_Percent_Decode_File
         (fin    : tmpl_stream_t;
          fout   : tmpl_stream_t;
          nbytes : out size_t)
          return size_t;
      pragma Import
         (C, Templatizer_Percent_Decode_File, "tmpl_percent_decode_file");

      N : size_t;
      Length : size_t;
   begin
      Length := Templatizer_Percent_Decode_File
         (tmpl_stream_t (Input), tmpl_stream_t (Output), N);
      X := Natural (N);
      return Natural (Length);
   end Percent_Decode_File;

   procedure Percent_Decode_Array
      (Input : String; Output : String)
   is
      function Templatizer_Percent_Decode_Array
         (input  : System.Address; inputlen  : size_t;
          output : System.Address; outputlen : size_t;
          nbytes : out size_t)
          return int;
      pragma Import
         (C,
          Templatizer_Percent_Decode_Array,
          "tmpl_percent_decode_array");

      R : int;
      N : size_t;
      S1, S2 : System.Address;
      Len1, Len2 : size_t;
   begin
      S1 := Input'Address;
      Len1 := Input'Length;
      S2 := Output'Address;
      Len2 := Output'Length;
      R := Templatizer_Percent_Decode_Array
         (S1, Len1,
          S2, Len2,
          N);
   end Percent_Decode_Array;

   procedure Parse_Query_String
      (Query : String)
   is
      procedure Templatizer_Parse_Query_String
         (query : chars_ptr;
          data  : System.Address;
          cb    : http_query_callback_t);
      pragma Import
         (C,
          Templatizer_Parse_Query_String,
          "tmpl_parse_query_string");

      S : chars_ptr := New_String (Query);
   begin
      Templatizer_Parse_Query_String (S, Null_Address, Null_Address);
      Free (S);
   end Parse_Query_String;

   procedure Parse_Query_String_Get
   is
      function Templatizer_Parse_Query_String_Get
         (data : System.Address;
          cb   : http_query_callback_t)
          return int;
      pragma Import
         (C,
          Templatizer_Parse_Query_String_Get,
          "tmpl_parse_query_string_get");

      R : int;
   begin
      R := Templatizer_Parse_Query_String_Get (Null_Address, Null_Address);
      if R /= 0 then
         raise Program_Error with "Unable to parse query string.";
      end if;
   end Parse_Query_String_Get;

   procedure Parse_Query_String_Post
   is
      function Templatizer_Parse_Query_String_Post
         (data : System.Address;
          cb   : http_query_callback_t)
          return int;
      pragma Import
         (C,
          Templatizer_Parse_Query_String_Post,
          "tmpl_parse_query_string_post");

      R : int;
   begin
      R := Templatizer_Parse_Query_String_Post
         (Null_Address, Null_Address);
      if R /= 0 then
         raise Program_Error with "Unable to parse query string.";
      end if;
   end Parse_Query_String_Post;

   procedure Query_String
      (Query : out Query_Vectors.Vector)
   is
      Method : constant String := "POST";
   begin
      if Method = "GET" then
         Parse_Query_String_Get;
      elsif Method = "POST" then
         Parse_Query_String_Post;
      end if;
   end Query_String;

end Templatizer.HTTP;
