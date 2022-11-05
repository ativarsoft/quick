with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;
with Ada.Directories;
use Ada.Directories;
with Ada.Exceptions;
use Ada.Exceptions;

package body Templatizer.Storage is

   function Begin_Transaction return Transaction is
      function Storage_Begin_Transaction (Handle : System.Address) return int;
      pragma Import
         (Convention => C,
          Entity => Storage_Begin_Transaction,
          External_Name => "storage_begin_transaction");
      T : Transaction;
   begin
      if Storage_Begin_Transaction (T.Handle'Address) /= 0 then
         raise Program_Error;
      end if;
      return T;
   end Begin_Transaction;

   procedure Initialize_Storage is
      function Initialize return int;
      pragma Import (C, Initialize, "storage_initialize");
      function Open (Filename : chars_ptr) return int;
      pragma Import (C, Open, "storage_open");
      function Home_Dir return chars_ptr;
      pragma Import (C, Home_Dir, "homedir");

      Home : constant String := Value (Home_Dir);
      S : constant String := Compose (Home, "templatizer");
      Path : chars_ptr := New_String (S);
   begin
      if Initialize /= 0 then
         raise Program_Error with "Unable to initialize storage";
      end if;
      begin
         Create_Directory (S);
      exception
         when others =>
            null;
      end;
      if Open (Path) /= 0 then
         raise Program_Error with "Unable to open storage file: " & S;
      end if;
   exception
      when E : others =>
         Free (Path);
         raise Storage_Error with Exception_Message (E);
   end Initialize_Storage;

   procedure Finalize_Storage is
   begin
      null;
   end Finalize_Storage;

end Templatizer.Storage;
