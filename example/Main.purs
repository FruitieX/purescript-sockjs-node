module Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe (Maybe(..))
import Node.HTTP as HTTP
import Node.Stream (end)
import SockJS.Server as SockJS

handleMessage
  :: forall e
   . SockJS.Connection
  -> SockJS.Message
  -> Eff (console :: CONSOLE | e) Unit
handleMessage conn message = do
  log $ "got message: " <> message
  SockJS.write conn message

handleConnection
 :: forall e
  . SockJS.Connection
 -> Eff (console :: CONSOLE | e) Unit
handleConnection conn = do
  log "client connected"
  SockJS.onData conn $ handleMessage conn
  SockJS.onClose conn $ log "client disconnected"

main
  :: forall e
   . Eff (http :: HTTP.HTTP, console :: CONSOLE | e) Unit
main = do
  http <- HTTP.createServer $
    -- dummy Node.HTTP request handler
    \req res -> end (HTTP.responseAsStream res) $ pure unit

  sockjs <- SockJS.createServer unit
  SockJS.installHandlers sockjs http "/sockjs"
  SockJS.onConnection sockjs handleConnection

  HTTP.listen http { hostname: "localhost", port: 8080, backlog: Nothing } $
    log "listening on port 8080."
