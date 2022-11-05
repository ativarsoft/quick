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

end Dav;
