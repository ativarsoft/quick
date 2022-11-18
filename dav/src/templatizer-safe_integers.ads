package Templatizer.Safe_Integers is

   type SafeInt is range 0 .. 2**31;

   overriding function "+" (Left, Right : SafeInt) return SafeInt;

end Templatizer.Safe_Integers;
