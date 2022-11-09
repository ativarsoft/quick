with Ada.Finalization;
use Ada.Finalization;
with System;

package Templatizer.Storage is

   type Transaction_Type is new Ada.Finalization.Controlled with record
      Handle : System.Address;
   end record;

   type Database_Type is new Ada.Finalization.Controlled with record
      Handle : System.Address;
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

end Templatizer.Storage;
