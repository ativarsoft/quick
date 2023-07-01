--  Copyright (C) 2023 Mateus de Lima Oliveira

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

package body Quick.Dating is

   procedure Display_Dating
   is
   begin
      Filler_Text ("Dating");
      Filler_Text ("elon-musk-is-gay-lol.jpg");
   exception
      when E : others =>
         Plain_Text;
         Send_Default_Headers;
   end Display_Dating;

   procedure Dating_Post
   is
   begin
      Filler_Text ("Dating");
      Filler_Text ("Bust_of_Satoshi_Nakamoto_in_Budapest.jpeg");
   end Dating_Post;

end Quick.Dating;
