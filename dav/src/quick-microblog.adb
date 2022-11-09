with Templatizer;
use Templatizer;
with Templatizer.Storage;
use Templatizer.Storage;

package body Quick.Microblog is

   procedure Display_Feed
   is
      Transaction : Transaction_Type := Begin_Transaction;
      Database : Database_Type'Class := Open_Database (Transaction);
   begin
      Start_While_Statement (True);
      Filler_Text ("Hello world!");
      Filler_Text ("Mateus");
      Filler_Text ("2022-11-01 13:50");

      --  tags
      Start_While_Statement (False);

      Start_While_Statement (False);
      Transaction.Commit;
      Database.Close;
   end Display_Feed;

end Quick.Microblog;
