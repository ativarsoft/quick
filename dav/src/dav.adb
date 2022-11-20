--  Copyright (C) 2022 Mateus de Lima Oliveira

with Ada.Directories;
use Ada.Directories;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Environment_Variables;
with GNAT.OS_Lib;
with Ada.Streams.Stream_IO;
with Templatizer;
use Templatizer;
with Templatizer.Storage;
use Templatizer.Storage;
with Quick.Microblog;
use Quick.Microblog;
with Templatizer.Safe_Integers;

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

   procedure Dump_File
   is
      package IO renames Ada.Streams.Stream_IO;
      F : IO.File_Type;
      File_Name : constant String := "/var/mateus/" & Get_Path_Info;
   begin
      IO.Open (F, IO.In_File, File_Name);
      IO.Close (F);
   end Dump_File;

   procedure Process_Request
   is
      use Ada.Environment_Variables;
      Method : constant String := Value ("REQUEST_METHOD");
      Script_Path : constant String := Get_Script_Path;
      Base : constant String := Simple_Name (Script_Path);
   begin
      Initialize_Storage;
      if Base = "dav.tmpl" then
         Filler_Text ("Hello World from Ada!");
         if Method = "PROPFIND" then
            Output_Dir_Content;
            Send_Default_Headers;
         elsif Method = "MKCOLL" then
            Put_Line ("Status: 201 Created");
            Send_Default_Headers;
            GNAT.OS_Lib.OS_Exit (0);
         elsif Method = "GET" then
            Dump_File;
         else
            Send_Default_Headers;
            GNAT.OS_Lib.OS_Exit (0);
         end if;
      elsif Base = "microblog.tmpl" then
         if Method = "GET" then
            Display_Feed;
         elsif Method = "POST" then
            Quick.Microblog.Post;
            Display_Feed;
         end if;
         Send_Default_Headers;
      else
         raise Program_Error with "Unknown file: " & Base;
      end if;
   exception
      when E : others =>
         Plain_Text;
         Send_Default_Headers;
         Put_Line (Exception_Message (E));
         GNAT.OS_Lib.OS_Exit (0);
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
