package Templatizer is

   function Get_Path_Info return String;
   procedure Send_Default_Headers;
   function Get_Script_Path return String;
   procedure Filler_Text (S : String);
   procedure If_Statement (Cond : Boolean);
   procedure Start_While_Statement (Cond : Boolean);

end Templatizer;
