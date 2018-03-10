module SockJS.Server where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Uncurried (EffFn1, EffFn2, EffFn3, mkEffFn1, runEffFn1, runEffFn2, runEffFn3)
import Node.HTTP as HTTP

-- | SockJS server object
foreign import data Server :: Type

-- | SockJS connection object
foreign import data Connection :: Type

-- | SockJS message that can be transmitted over a connection
type Message = String

-- | Prefix passed to sockjsServer.installHandlers
type Prefix = String

-- Server methods
foreign import createServer_
  :: forall e
   . EffFn1 e
       Unit
       Server

foreign import installHandlers_
  :: forall e
   . EffFn3 e
       Server
       HTTP.Server
       Prefix
       Unit

foreign import onConnection_
  :: forall e
   . EffFn2 e
       Server
       (EffFn1 e Connection Unit)
       Unit

-- Connection methods
foreign import write_
  :: forall e
   . EffFn2 e
       Connection
       Message
       Unit

foreign import end_
  :: forall e
   . EffFn1 e
       Connection
       Unit

foreign import onData_
  :: forall e
   . EffFn2 e
       Connection
       (EffFn1 e Message Unit)
       Unit

foreign import onClose_
  :: forall e
   . EffFn2 e
       Connection
       (Eff e Unit)
       Unit

-- Creates a new SockJS server instance
createServer
  :: forall e
   . Unit
  -> Eff e Server
createServer = runEffFn1 createServer_

-- | Installs SockJS' handlers into given Node.Server instance
installHandlers
  :: forall e
   . Server
  -> HTTP.Server
  -> Prefix
  -> Eff e Unit
installHandlers server prefix httpServer =
  runEffFn3 installHandlers_ server prefix httpServer

-- | Attaches a connection event handler to a Server
onConnection
  :: forall e
   . Server
  -> (Connection -> Eff e Unit)
  -> Eff e Unit
onConnection server callback =
  runEffFn2 onConnection_ server $ mkEffFn1 callback

-- | Write a message over a Connection
write
  :: forall e
   . Connection
  -> Message
  -> Eff e Unit
write conn message =
  runEffFn2 write_ conn message

-- | Close a Connection
end
  :: forall e
   . Connection
  -> Eff e Unit
end conn =
  runEffFn1 end_ conn

-- | Attaches a data event handler to a Connection
onData
  :: forall e
   . Connection
  -> (Message -> Eff e Unit)
  -> Eff e Unit
onData conn callback =
  runEffFn2 onData_ conn $ mkEffFn1 callback

-- | Attaches a close event handler to a Connection
onClose
  :: forall e
   . Connection
  -> Eff e Unit
  -> Eff e Unit
onClose conn callback =
  runEffFn2 onClose_ conn callback
