--  Copyright (C) 2023 Mateus de Lima Oliveira

with System;
use System;
with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;

package body Templatizer.Rest is

   type Curl_Type is new System.Address;

   procedure Rest (URL : String; Request_Body : String)
   is

      function Templatizer_Curl_Init (Handle : out Curl_Type)
         return int;
      pragma Import
         (Convention => C,
          Entity => Templatizer_Curl_Init,
          External_Name => "tmpl_curl_init");

      function Templatizer_Curl_Cleanup (Handle : Curl_Type)
         return int;
      pragma Import
         (Convention => C,
          Entity => Templatizer_Curl_Cleanup,
          External_Name => "tmpl_curl_cleanup");

      function Templatizer_Curl_Perform (Handle : Curl_Type)
         return int;
      pragma Import
         (Convention => C,
          Entity => Templatizer_Curl_Perform,
          External_Name => "tmpl_curl_perform");

      function Templatizer_Curl_Set_Url
         (Handle : Curl_Type;
          Url : chars_ptr)
         return int;
      pragma Import
         (Convention => C,
          Entity => Templatizer_Curl_Set_Url,
          External_Name => "tmpl_curl_set_url");

      Handle : Curl_Type := Curl_Type (Null_Address);

      Return_Code : int := 1;

      C_Url : chars_ptr;

   begin
      Return_Code := Templatizer_Curl_Init (Handle);
      if Return_Code /= 0 or Handle = Curl_Type (Null_Address) then
         raise Program_Error with "Failed to initialize libcurl.";
      end if;
      Return_Code := Templatizer_Curl_Perform (Handle);
      if Return_Code /= 0 then
         raise Program_Error with "Failed to perform HTTP request.";
      end if;
      C_Url := New_String (Url);
      Return_Code := Templatizer_Curl_Set_Url (Handle, C_Url);
      Free (C_Url);
      if Return_Code /= 0 then
          raise Program_Error with "Failed to set URL option for HTTP request.";
      end if;
      Return_Code := Templatizer_Curl_Cleanup (Handle);
      if Return_Code /= 0 then
         raise Program_Error with "Failed to clean up HTTP request.";
      end if;
   end Rest;

end Templatizer.Rest;

