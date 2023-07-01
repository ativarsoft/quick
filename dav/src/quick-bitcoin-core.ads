-- Copyright (C) 2023 Mateus de Lima Oliveira

-- Bitcoin Core's JSON-RPC service

-- This JSON API is specific to the Bitcoin Core reference client.
-- WARNING: Issues may arise if you try to use this with other clients and you
-- may loose money. Do not do it.

with Quick.Bitcoin;
use Quick.Bitcoin;
with Ada.Strings.Unbounded;
use Ada.Strings.Unbounded;

package Quick.Bitcoin.Core is

   pragma Elaborate_Body;

   function Send (Address: Bitcoin_Address_Type; Amount: Natural)
      return Unbounded_String;
   -- Amount is in satoshis.

end Quick.Bitcoin.Core;

