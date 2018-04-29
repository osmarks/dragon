# Dragon
A centralized storage management system for Minecraft.
Requires Plethora Peripherals by SquidDev and ideally CC: Tweaked.

## Setup
### Networking & Hardware

```
Chests ───────┐
   │          │
Server ─── Buffer
   │          │
   └────┬─────┘
        │
        ├────────── Processing (not implemented yet)
        ├────────── Introspection Module in manipulator (optional)
        │
   ┌────┴──┬───────┐
Client  Client  Client
```
**Chests** is a set of chests and/or shulker boxes, connected via networking cables and modems, to the **Server** and **Buffer**.
**Buffer** is a set of two droppers, each with two wired connections - one on the internal side, connected to the chests, and one on the external side, connected to the clients.
**Server** is a computer running `server.lua`. It must be connected to the chests, clients, and both sides of the buffers.
**Client** is a crafty turtle running `client.lua`. It must be connected to the server and external side of the buffers.
**Processing** will be used for autocrafting systems. It is not yet implemented.
**Introspection Module** is an introspection module, bound to a user, in a manipulator. To use it, it must be connected to a client with it configured, and the external side of the buffers. It is recommended that you interact with the client connected to it via a Plethora keyboard.

### Configuration
Configuration must be saved in a file called `conf` (no `.lua` extension). It is in lua table/textutils.serialise syntax.

#### Server/Client
Both server and client require `modem` keys indicating which side their (connected) modems are on.

#### Client
A client requires a `name` key indicating its name on the network. This should be displayed when you rightclick its modem.
If you are using an introspection module, an `introspection` key must be added, indicating the network name of the manipulator it is in.

#### Server
`buffer(In/Out)(External/Internal)` keys must contain the network names of each buffer dropper on the chest-side and client-side networks.
Which buffer is external or internal does not matter, as long as the internal and external network names for out and in point to the same inventory.

## Warnings
* Inserting/extracting items manually into/out of chests will result in the index being desynchronised with the actual items. To remedy this, run `r` in the CLI after doing so.
* Items with different names but the same ID/metadata may be labelled under the wrong name, as the system uses caching to avoid lag-inducing calls on every slot of chests.
* Errors are likely to be very cryptic in this version, as I have not implemented proper error handling.