with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;
with Ada.Directories;
use Ada.Directories;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Environment_Variables;
with GNAT.OS_Lib;

package body Dav is

   procedure Output_Dir_Content;

   procedure Initialize_Dav is
      --  procedure Initialize;
      --  pragma Import
      --     (Convention    => C,
      --      Entity        => Initialize,
      --      External_Name => "adainit");
   begin
      --  Initialize;
      null;
      Process_Request;
   exception
      when E : others =>
         Put_Line (Exception_Message (E));
   end Initialize_Dav;

   procedure Finalize_Dav is
      --  procedure Finalize;
      --  pragma Import
      --     (Convention    => C,
      --      Entity        => Finalize,
      --      External_Name => "adafinal");
   begin
      --  Finalize;
      null;
   end Finalize_Dav;

   function Get_Path_Info return String
   is
      function Dav_Path_Info return chars_ptr;
      pragma Import
         (Convention    => C,
          Entity        => Dav_Path_Info,
          External_Name => "dav_path_info");
   begin
      return Interfaces.C.Strings.Value (Dav_Path_Info);
   end Get_Path_Info;

   procedure Send_Default_Headers
   is
      procedure Dav_Send_Default_Headers;
      pragma Import
         (Convention    => C,
          Entity        => Dav_Send_Default_Headers,
          External_Name => "dav_send_default_headers");
   begin
      Dav_Send_Default_Headers;
   end Send_Default_Headers;

   procedure Filler_Text (S : String)
   is
      procedure Dav_Filler_Text (S : chars_ptr);
      pragma Import
         (Convention    => C,
          Entity        => Dav_Filler_Text,
          External_Name => "dav_filler_text");
      Heap_String : chars_ptr;
   begin
      Heap_String := New_String (S);
      Dav_Filler_Text (Heap_String);
      Free (Heap_String);
   end Filler_Text;

   procedure If_Statement (Cond : Boolean)
   is
      procedure Dav_If (A : int);
      pragma Import
          (Convention    => C,
           Entity        => Dav_If,
           External_Name => "dav_if");

      A : int := 0;
   begin
      if Cond then
         A := 1;
      end if;
      Dav_If (A);
   end If_Statement;

   procedure Start_While_Statement (Cond : Boolean)
   is
      procedure Dav_Swhile (a : int);
      pragma Import
         (Convention    => C,
          Entity        => Dav_Swhile,
          External_Name => "dav_swhile");

      A : int := 0;
   begin
      if Cond then
         A := 1;
      end if;
      Dav_Swhile (A);
   end Start_While_Statement;

   procedure Process_Request
   is
      use Ada.Environment_Variables;
      Method : constant String := Value ("REQUEST_METHOD");
   begin
      Filler_Text ("Hello World from Ada!");
      if Method = "PROPFIND" then
         Output_Dir_Content;
         Send_Default_Headers;
      elsif Method = "MKCOLL" then
         Put_Line ("Status: 201 Created");
         Send_Default_Headers;
         GNAT.OS_Lib.OS_Exit (0);
      else
         Send_Default_Headers;
         GNAT.OS_Lib.OS_Exit (0);
      end if;
   end Process_Request;

   procedure Output_Dir_Content
   is
      Dir : Directory_Entry_Type;
      Dir_Search : Search_Type;

      Curr_Dir : constant String := Current_Directory;
   begin
      Start_Search
         (Search => Dir_Search,
          Directory => Curr_Dir,
          Pattern => "*");
      loop

         Start_While_Statement (True);
         Get_Next_Entry (Dir_Search, Dir);

         if Kind (Dir) = Ordinary_File then
            If_Statement (True);
            Filler_Text (Full_Name (Dir));
            Filler_Text (Size (Dir)'Image);
         else
            If_Statement (False);
         end if;

         exit when not More_Entries (Dir_Search);

      end loop;

      Start_While_Statement (False);

      End_Search (Dir_Search);
   end Output_Dir_Content;

end Dav;
