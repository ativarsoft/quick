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

with Quick.Bitcoin.Core;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;
with Templatizer.Rest;
use Templatizer.Rest;

package body Quick.Dating is

   package Bitcoin renames Quick.Bitcoin.Core;

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
      Request_Body : Unbounded_String;
   begin
      Filler_Text ("Dating");
      Filler_Text ("Bust_of_Satoshi_Nakamoto_in_Budapest.jpeg");
      -- Send one satoshi to Satoshi Nakamoto if you want to date them.
      Request_Body := Bitcoin.Send ("1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa", 1);
      Templatizer.Rest.Rest ("http://localhost", To_String (Request_Body));
   end Dating_Post;

end Quick.Dating;
