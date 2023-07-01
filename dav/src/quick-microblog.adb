--  Copyright (C) 2022 Mateus de Lima Oliveira

with Templatizer;
use Templatizer;
with Templatizer.Storage;
use Templatizer.Storage;
with Templatizer.HTTP;
use Templatizer.HTTP;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Exceptions;
use Ada.Exceptions;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Ada.Calendar;
use Ada.Calendar;
with Ada.Calendar.Formatting;
use Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones;
use Ada.Calendar.Time_Zones;

package body Quick.Microblog is

   procedure Display_Post
      (Transaction : Transaction_Type'Class;
       Database : Database_Type'Class)
   is
      Text : constant String := Get (Transaction, Database, 1);
      Name : constant String := Get (Transaction, Database, 2);
      Date_Time : constant String := Get (Transaction, Database, 3);
      Categories : constant String := Get (Transaction, Database, 4);
   begin
      --  Profile photo
      Filler_Text ("me.jpg");

      Start_While_Statement (True);
      --  Filler_Text ("Hello world!");
      Filler_Text (Text);
      --  Filler_Text ("Mateus");
      Filler_Text (Name);
      --  Filler_Text ("2022-11-01 13:50");
      Filler_Text (Date_Time);

      --  TODO: parse tags.

      --  tags
      Start_While_Statement (True);
      Filler_Text (Categories);
      Start_While_Statement (False);

      Start_While_Statement (False);
   end Display_Post;

   procedure Display_Feed
   is
      Transaction : Transaction_Type := Begin_Transaction;
      Database : Database_Type'Class := Open_Database (Transaction);
   begin
      --  TODO: call this function for each post.
      Display_Post (Transaction, Database);
      Transaction.Commit;
      Database.Close;
   exception
      when E : others =>
         Plain_Text;
         Send_Default_Headers;
         Put_Line (Exception_Message (E));
         Transaction.Cancel;
         Transaction := Begin_Transaction;
         Database := Open_Database (Transaction);
         Put (Transaction, Database, 1, "Hello world!");
         Put (Transaction, Database, 2, "Mateus");
         Put (Transaction, Database, 3, "2022-11-01 13:50");
         Put (Transaction, Database, 4, "lol");
         Transaction.Commit;
         Database.Close;
         raise Program_Error with "Error loading feed.";
   end Display_Feed;

   procedure Post
   is
      Transaction : Transaction_Type := Begin_Transaction;
      Database : Database_Type'Class := Open_Database (Transaction);
      Query : constant Query_Vectors.Vector := Query_String;
      Text_Unbounded : Unbounded_String;
      Categories_Unbounded : Unbounded_String;
      I : Natural;
      Now : Time := Clock;
   begin
      I := 0;
      loop
         exit when I >= Natural (Query.Length);
         if Query (I) = To_Unbounded_String ("text") then
            Text_Unbounded := Query (I + 1);
         elsif Query (I) = To_Unbounded_String ("categories") then
            Categories_Unbounded := Query (I + 1);
         end if;
         I := I + 2;
      end loop;
      --  REMOVE ME: test data.
      --  Put (Transaction, Database, 1, "Hello world!");
      Put (Transaction, Database, 1, To_String (Text_Unbounded));
      Put (Transaction, Database, 2, "Mateus");
      --  Put (Transaction, Database, 3, "2022-11-01 13:50");
      Put (Transaction, Database, 3, Image (Now, False, -3 * 60));
      Put (Transaction, Database, 4, To_String (Categories_Unbounded));
      Transaction.Commit;
      Database.Close;
      Display_Feed;
   exception
      when E : others =>
         Plain_Text;
         Send_Default_Headers;
         Put_Line (Exception_Message (E));
         Transaction.Cancel;
         Database.Close;
         raise Program_Error with "Unable to save post.";
   end Post;

end Quick.Microblog;
