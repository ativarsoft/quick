--  Copyright (C) 2023 Mateus de Lima Oliveira

with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package body Quick.Bitcoin.Core is

   function Send (Address: Bitcoin_Address_Type; Amount: Natural)
      return Unbounded_String
   is
      Request_Body : Unbounded_String := To_Unbounded_String ("");
   begin
      Request_Body := Request_Body & "[";
      Request_Body := Request_Body & "{";
      Request_Body := Request_Body & """";
      Request_Body := Request_Body & String (Address);
      Request_Body := Request_Body & """";
      Request_Body := Request_Body & ":";
      Request_Body := Request_Body & Amount'Image;
      Request_Body := Request_Body & "}";
      Request_Body := Request_Body & "]";
      return Request_Body;
   end Send;

end Quick.Bitcoin.Core;

