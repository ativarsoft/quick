with Ada.Finalization;
use Ada.Finalization;
with System;

package Templatizer.Storage is

   type Transaction is new Ada.Finalization.Controlled with record
      Handle : System.Address;
   end record;

   procedure Initialize_Storage;
   procedure Finalize_Storage;
   function Begin_Transaction return Transaction;

end Templatizer.Storage;
