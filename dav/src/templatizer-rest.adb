--  Copyright (C) 2023 Mateus de Lima Oliveira

with Interfaces.C.Strings;
use Interfaces.C.Strings;

package body Templatizer.Rest is

   procedure Rest (URL : String; Request_Body : String)
   is
      procedure Templatizer_Rest (URL: chars_ptr; Request_Body: chars_ptr);
      pragma Import
         (Convention => C,
          Entity => Templatizer_Rest,
          External_Name => "tmpl_rest");
   begin
      null;
   end Rest;

end Templatizer.Rest;

