with Ada.Finalization;
use Ada.Finalization;
with System;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Templatizer.Storage is

   type Transaction_Type is new Ada.Finalization.Controlled with record
      Handle : System.Address;
   end record;

   type Database_Type is new Ada.Finalization.Controlled with record
      Handle : System.Address;
   end record;

   type Database_Type_Discriminant is
      (Database_String,
       Database_Integer);

   type Value_Type (T : Database_Type_Discriminant) is record
      Next_ID : Natural;
      case T is
         when Database_String =>
            String_Data : Unbounded_String;
         when Database_Integer =>
            Integer_Data : Integer;
      end case;
   end record;

   procedure Initialize_Storage;

   procedure Finalize_Storage;

   function Begin_Transaction return Transaction_Type;

   procedure Commit
      (T : in out Transaction_Type);

   procedure Cancel
      (T : in out Transaction_Type);

   --  NOTE: Operation can be dispatching in only one type.
   --  A class-wide parameter isn't dispatching.
   function Open_Database
       (Transaction : in out Transaction_Type)
        return Database_Type'Class;

   procedure Close
      (DB : in out Database_Type);

   function Get
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural)
       return String;

   function Get
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural)
       return Integer;

   procedure Put
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural;
       Value       : String);

   procedure Put
      (Transaction : Transaction_Type'Class;
       Database    : Database_Type'Class;
       Key_ID      : Natural;
       Value       : Integer);

end Templatizer.Storage;
