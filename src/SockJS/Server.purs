module SockJS.Server where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, mkEffectFn1, runEffectFn1, runEffectFn2, runEffectFn3)
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
  :: Effect Server

foreign import installHandlers_
  :: EffectFn3
       Server
       HTTP.Server
       Prefix
       Unit

foreign import onConnection_
  :: EffectFn2
       Server
       (EffectFn1 Connection Unit)
       Unit

-- Connection methods
foreign import write_
  :: EffectFn2
       Connection
       Message
       Unit

foreign import end_
  :: EffectFn1
       Connection
       Unit

foreign import onData_
  :: EffectFn2
       Connection
       (EffectFn1 Message Unit)
       Unit

foreign import onClose_
  :: EffectFn2
       Connection
       (Effect Unit)
       Unit

-- Creates a new SockJS server instance
createServer
  :: Effect Server
createServer = createServer_

-- | Installs SockJS' handlers into given Node.Server instance
installHandlers
  :: Server
  -> HTTP.Server
  -> Prefix
  -> Effect Unit
installHandlers server prefix httpServer =
  runEffectFn3 installHandlers_ server prefix httpServer

-- | Attaches a connection event handler to a Server
onConnection
  :: Server
  -> (Connection -> Effect Unit)
  -> Effect Unit
onConnection server callback =
  runEffectFn2 onConnection_ server $ mkEffectFn1 callback

-- | Write a message over a Connection
write
  :: Connection
  -> Message
  -> Effect Unit
write conn message =
  runEffectFn2 write_ conn message

-- | Close a Connection
end
  :: Connection
  -> Effect Unit
end conn =
  runEffectFn1 end_ conn

-- | Attaches a data event handler to a Connection
onData
  :: Connection
  -> (Message -> Effect Unit)
  -> Effect Unit
onData conn callback =
  runEffectFn2 onData_ conn $ mkEffectFn1 callback

-- | Attaches a close event handler to a Connection
onClose
  :: Connection
  -> Effect Unit
  -> Effect Unit
onClose conn callback =
  runEffectFn2 onClose_ conn callback
