with Interfaces.C.Strings;
use Interfaces.C.Strings;

package body Dav is

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

   procedure Process_Request is
   begin
      Send_Default_Headers;
      Filler_Text ("Hello World from Ada!");
   end Process_Request;

end Dav;
