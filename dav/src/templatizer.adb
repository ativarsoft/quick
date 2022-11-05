with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;

package body Templatizer is

   function Get_Path_Info return String
   is
      function Templatizer_Path_Info return chars_ptr;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Path_Info,
          External_Name => "tmpl_get_path_info");
   begin
      return Interfaces.C.Strings.Value (Templatizer_Path_Info);
   end Get_Path_Info;

   procedure Send_Default_Headers
   is
      procedure Templatizer_Send_Default_Headers;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Send_Default_Headers,
          External_Name => "tmpl_send_default_headers");
   begin
      Templatizer_Send_Default_Headers;
   end Send_Default_Headers;

   function Get_Script_Path return String
   is
      function Templatizer_Get_Script_Path return chars_ptr;
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Get_Script_Path,
          External_Name => "tmpl_get_script_path");

      Ptr : chars_ptr;
   begin
      Ptr := Templatizer_Get_Script_Path;
      declare
         S : constant String := Value (Ptr);
      begin
         return S;
      end;
   end Get_Script_Path;

   procedure Filler_Text (S : String)
   is
      procedure Templatizer_Filler_Text (S : chars_ptr);
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Filler_Text,
          External_Name => "tmpl_filler_text");
      Heap_String : chars_ptr;
   begin
      Heap_String := New_String (S);
      Templatizer_Filler_Text (Heap_String);
      Free (Heap_String);
   end Filler_Text;

   procedure If_Statement (Cond : Boolean)
   is
      procedure Templatizer_If (A : int);
      pragma Import
          (Convention    => C,
           Entity        => Templatizer_If,
           External_Name => "tmpl_if");

      A : int := 0;
   begin
      if Cond then
         A := 1;
      end if;
      Templatizer_If (A);
   end If_Statement;

   procedure Start_While_Statement (Cond : Boolean)
   is
      procedure Templatizer_Swhile (a : int);
      pragma Import
         (Convention    => C,
          Entity        => Templatizer_Swhile,
          External_Name => "tmpl_swhile");

      A : int := 0;
   begin
      if Cond then
         A := 1;
      end if;
      Templatizer_Swhile (A);
   end Start_While_Statement;

end Templatizer;
