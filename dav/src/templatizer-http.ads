with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Templatizer.HTTP is

   package Query_Vectors is new Ada.Containers.Vectors
      (Index_Type => Natural,
       Element_Type => Unbounded_String);

   procedure Query_String
      (Query : out Query_Vectors.Vector);

end Templatizer.HTTP;
