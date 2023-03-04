--  Copyright (C) 2022 Mateus de Lima Oliveira

--  with Ada.Strings.UTF_Encoding;
--  use Ada.Strings.UTF_Encoding;

--  with Ada.Strings.Wide_Unbounded;
--  use Ada.Strings.Wide_Unbounded;

package Templatizer is

   --  subtype String is Wide_String;
   --  subtype Unbounded_String is Unbounded_Wide_String;

   --  function To_Templatizer_String (S : Standard.String) return Wide_String renames To_Wide_String;

   function Get_Path_Info return String;
   procedure Plain_Text;
   procedure Send_Default_Headers;
   function Get_Script_Path return String;
   procedure Filler_Text (S : String);
   procedure If_Statement (Cond : Boolean);
   procedure Start_While_Statement (Cond : Boolean);

end Templatizer;
