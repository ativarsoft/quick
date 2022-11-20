--  Copyright (C) 2022 Mateus de Lima Oliveira

with Interfaces.C;
use Interfaces.C;

package body Templatizer.Safe_Integers is

   function "+" (Left, Right : SafeInt) return SafeInt
   is
      function Add (Left, Right : SafeInt; Result : out SafeInt) return int;
      pragma Import (C, Add, "tmpl_add");
      Result : SafeInt;
   begin
      if Add (Left, Right, Result) /= 0 then
         raise Program_Error with "Integer overflow.";
      end if;
      return Result;
   end "+";

end Templatizer.Safe_Integers;
