--  Copyright (C) 2022 Mateus de Lima Oliveira

with Interfaces.C;
use Interfaces.C;
with Interfaces.C.Strings;
use Interfaces.C.Strings;
with Ada.Directories;
use Ada.Directories;
with Ada.Exceptions;
use Ada.Exceptions;

package body Templatizer.Storage is

   procedure Put
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural;
       Value       : String)
   is
      function Storage_Put_String
         (Transaction  : System.Address;
          Database     : System.Address;
          Key_ID       : int;
          Value_Data   : chars_ptr;
          Value_Length : int)
          return int;
      pragma Import (C, Storage_Put_String, "storage_put_string");

      Value_Data_Ptr : chars_ptr := New_String (Value);
      Value_Length   : constant int := Value'Length;
   begin
      if Storage_Put_String
         (Transaction.Handle,
          Database.Handle,
          int (Key_ID),
          Value_Data_Ptr,
          Value_Length) /= 0
      then
         Free (Value_Data_Ptr);
         raise Program_Error with "Unable to write on the database.";
      end if;
      Free (Value_Data_Ptr);
   end Put;

   procedure Put
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural;
       Value       : Integer)
   is
      function Storage_Put_Integer
         (Transaction : System.Address;
          Database : System.Address;
          Key_ID : int;
          Value : int)
          return int;
      pragma Import (C, Storage_Put_Integer, "storage_put_integer");
   begin
      if Storage_Put_Integer
         (Transaction.Handle,
          Database.Handle,
          int (Key_ID),
          int (Value)) /= 0
      then
         raise Program_Error with "Error writing to the database.";
      end if;
   end Put;

   function Get
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural)
       return String
   is
      function Storage_Get_String
         (Transaction : System.Address;
          Database    : System.Address;
          Key_ID      : int;
          Value       : out chars_ptr)
          return int;
      pragma Import (C, Storage_Get_String, "storage_get_string");

      Value_Data_Ptr : chars_ptr;
   begin
      if Storage_Get_String
         (Transaction.Handle,
          Database.Handle,
          int (Key_ID),
          Value_Data_Ptr) /= 0
      then
         raise Program_Error with "Error getting getting database value.";
      end if;
      declare
         S : constant String := Value (Value_Data_Ptr);
      begin
         Free (Value_Data_Ptr);
         return S;
      end;
   end Get;

   function Get
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural)
       return Integer
   is
      function Storage_Get_Integer
         (Transaction : System.Address;
          Database    : System.Address;
          Key_ID      : int;
          Value       : out int)
          return int;
      pragma Import (C, Storage_Get_Integer, "storage_get_integer");

      Value : int := 0;
   begin
      if Storage_Get_Integer
         (Transaction.Handle,
          Database.Handle,
          int (Key_ID),
          Value) /= 0
      then
         raise Program_Error with "Error getting getting database value.";
      end if;
      return Integer (Value);
   end Get;

   function Begin_Transaction
      return Transaction_Type
   is
      function Storage_Begin_Transaction
         (Handle : out System.Address)
          return int;
      pragma Import
         (Convention => C,
          Entity => Storage_Begin_Transaction,
          External_Name => "storage_begin_transaction");
      T : Transaction_Type;
   begin
      if Storage_Begin_Transaction (T.Handle) /= 0 then
         raise Program_Error;
      end if;
      return T;
   end Begin_Transaction;

   procedure Commit (T : in out Transaction_Type)
   is
      procedure Storage_Commit_Transaction
         (Handle : System.Address);
      pragma Import
         (Convention    => C,
          Entity        => Storage_Commit_Transaction,
          External_Name => "storage_commit_transaction");
   begin
      Storage_Commit_Transaction (T.Handle);
   end Commit;

   procedure Cancel (T : in out Transaction_Type)
   is
      procedure Storage_Abort_Transaction
         (Handle : System.Address);
      pragma Import
         (Convention    => C,
          Entity        => Storage_Abort_Transaction,
          External_Name => "storage_abort_transaction");
   begin
      Storage_Abort_Transaction (T.Handle);
   end Cancel;

   function Open_Database
      (Transaction : in out Transaction_Type)
       return Database_Type'Class
   is
      function Storage_Open_Database
         (Transaction : System.Address;
          Database : out System.Address)
          return int;
      pragma Import (C, Storage_Open_Database, "storage_open_database");

      Database : Database_Type;
   begin
      if Storage_Open_Database (Transaction.Handle, Database.Handle) /= 0 then
         raise Program_Error with "Unable to open database";
      end if;
      return Database;
   end Open_Database;

   procedure Close (DB : in out Database_Type)
   is
      function Storage_Close_Database
         (Database : System.Address)
          return int;
      pragma Import (C, Storage_Close_Database, "storage_close_database");
   begin
      if Storage_Close_Database (DB.Handle) /= 0 then
         raise Program_Error with "Error while closing database.";
      end if;
   end Close;

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
