--  Copyright (C) 2022 Mateus de Lima Oliveira

with System;
use System;
with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;
with Ada.Environment_Variables;
with System.Address_To_Access_Conversions;

package body Templatizer.HTTP is

   package Query_Conversion is new System.Address_To_Access_Conversions (Query_Vectors.Vector);

   type http_cookie_callback_t is access procedure
      (data : System.Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t)
      with Convention => C;

   type http_query_callback_t is access procedure
      (data : System.Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t)
      with Convention => C;

   subtype tmpl_stream_t is System.Address;

   type Stream is new tmpl_stream_t;

   function Percent_Decoded_Len
      (Query : String)
      return Natural;

   procedure Percent_Decode_Array
      (Input : String; Output : String);

   procedure Cookie_Callback
      (data : Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t);
   pragma Convention (Convention => C, Entity => Cookie_Callback);

   procedure Query_Callback
      (data : Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t);
   pragma Convention (Convention => C, Entity => Query_Callback);

   procedure Cookie_Callback
      (data : Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t)
   is
      V : Cookie_Vectors.Vector;
      for V'Address use data;

      Key_String : String := Interfaces.C.Strings.Value (key);
      Value_String : String := Interfaces.C.Strings.Value (value);

      Key_Unbounded : Unbounded_String := To_Unbounded_String (Key_String);
      Value_Unbounded : Unbounded_String := To_Unbounded_String (Value_String);
   begin
      V.Append (Key_Unbounded);
      V.Append (Value_Unbounded);
   end Cookie_Callback;

   procedure Query_Callback
      (data : Address;
       key : chars_ptr; key_len : size_t;
       value : chars_ptr; value_len : size_t)
   is
      V : access Query_Vectors.Vector := Query_Conversion.To_Pointer (data);
      --  for V'Address use data;

      Key_Full : String := Interfaces.C.Strings.Value (key);
      Value_Full : String := Interfaces.C.Strings.Value (value);

      Key_String : String := Key_Full (1 .. Integer (key_len));
      Value_String : String := Value_Full (1 .. Integer (value_len));
   begin
      declare
         Decoded_Key : String (1 .. Percent_Decoded_Len (Key_String));
         Decoded_Value : String (1 .. Percent_Decoded_Len (Value_String));
      begin
         Percent_Decode_Array (Key_String, Decoded_Key);
         Percent_Decode_Array (Value_String, Decoded_Value);
         V.Append (To_Unbounded_String (Decoded_Key (1 .. Decoded_Key'Length - 1)));
         V.Append (To_Unbounded_String (Decoded_Value (1 .. Decoded_Value'Length -1)));
      end;
   end Query_Callback;

   procedure Parse_Cookie_String
   is
      function Templatizer_Parse_Cookie_String
         (data : System.Address;
          cb : http_cookie_callback_t)
          return int;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Parse_Cookie_String,
          External_Name => "tmpl_parse_cookie_string");

      R : int;
   begin
      R := Templatizer_Parse_Cookie_String
         (System.Null_Address, Cookie_Callback'Access);

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
         (Convention    => C,
          Entity        => Templatizer_Percent_Decoded_Len,
          External_Name => "tmpl_percent_decoded_len");

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
         (Convention    => C,
          Entity        => Templatizer_Percent_Decode_File,
          External_Name => "tmpl_percent_decode_file");

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
         (input  : Address; inputlen  : size_t;
          output : Address; outputlen : size_t;
          nbytes : out size_t)
          return int;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Percent_Decode_Array,
          External_Name => "tmpl_percent_decode_array");

      R : int;
      N : size_t;
      S1, S2 : Address;
      Len1, Len2 : size_t;
   begin
      S1 := Input'Address;
      Len1 := Input'Length + 1;
      S2 := Output'Address;
      Len2 := Output'Length;
      R := Templatizer_Percent_Decode_Array
         (S1, Len1,
          S2, Len2,
          N);
      if R = 0 then
         raise Program_Error with
            "Error percent decoding array. " &
            "Input length is " & Len1'Image &
            " and output length is" & Len2'Image & ".";
      end if;
      if N < Len2 - 1 then
         raise Program_Error with
            "Decoded" & N'Image & "bytes out of" & Len2'Image & "bytes.";
      end if;
   end Percent_Decode_Array;

   function Parse_Query_String
      (Query : String)
       return Query_Vectors.Vector
   is
      procedure Templatizer_Parse_Query_String
         (query : chars_ptr;
          data  : System.Address;
          cb    : http_query_callback_t);
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Parse_Query_String,
          External_Name => "tmpl_parse_query_string");

      S : chars_ptr := New_String (Query);
      V : Query_Vectors.Vector;
   begin
      Templatizer_Parse_Query_String (S, V'Address, Query_Callback'Access);
      Free (S);
      return V;
   end Parse_Query_String;

   procedure Parse_Query_String_Get
   is
      function Templatizer_Parse_Query_String_Get
         (data : System.Address;
          cb   : http_query_callback_t)
          return int;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Parse_Query_String_Get,
          External_Name => "tmpl_parse_query_string_get");

      R : int;
      V : Query_Vectors.Vector;
   begin
      R := Templatizer_Parse_Query_String_Get
         (V'Address, Query_Callback'Access);
      if R /= 0 then
         raise Program_Error with "Unable to parse query string.";
      end if;
   end Parse_Query_String_Get;

   function Parse_Query_String_Post
      return Query_Vectors.Vector
   is
      function Templatizer_Parse_Query_String_Post
         (data : System.Address;
          cb   : http_query_callback_t)
          return int;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Parse_Query_String_Post,
          External_Name => "tmpl_parse_query_string_post");

      R : int;
      V : Query_Vectors.Vector;
   begin
      R := Templatizer_Parse_Query_String_Post
         (V'Address, Query_Callback'Access);
      if R /= 0 then
         raise Program_Error with "Unable to parse query string.";
      end if;
      return V;
   end Parse_Query_String_Post;

   function Query_String
      return Query_Vectors.Vector
   is
      Method : constant String := Ada.Environment_Variables.Value ("REQUEST_METHOD");
      Query : Query_Vectors.Vector;
   begin
      if Method = "GET" then
         Parse_Query_String_Get;
      elsif Method = "POST" then
         Query := Parse_Query_String_Post;
      else
         raise Program_Error with "Unknown method.";
      end if;
      return Query;
   end Query_String;

end Templatizer.HTTP;
