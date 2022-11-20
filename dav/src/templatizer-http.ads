--  Copyright (C) 2022 Mateus de Lima Oliveira

with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Templatizer.HTTP is

   package Cookie_Vectors is new Ada.Containers.Vectors
      (Index_Type => Natural,
       Element_Type => Unbounded_String);

   package Query_Vectors is new Ada.Containers.Vectors
      (Index_Type => Natural,
       Element_Type => Unbounded_String);

   function Query_String
      return Query_Vectors.Vector;

end Templatizer.HTTP;
