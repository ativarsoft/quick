with Interfaces.C;
use Interfaces.C;

package Dav is

   procedure Initialize_Dav;
   pragma Export
      (Convention    => C,
       Entity        => Initialize_Dav,
       External_Name => "initialize_dav");

   procedure Finalize_Dav;
   pragma Export
      (Convention    => C,
       Entity        => Finalize_Dav,
       External_Name => "finalize_dav");

   procedure Process_Request;
   pragma Export
      (Convention    => C,
       Entity        => Process_Request,
       External_Name => "process_request");

   procedure Send_Default_Headers;

   procedure Filler_Text (S : String);

   procedure If_Statement (Cond : Boolean);

   procedure Start_While_Statement (a : int);
   pragma Import
      (Convention    => C,
       Entity        => Start_While_Statement,
       External_Name => "dav_swhile");

end Dav;
