module PgenieCli.App (run) where

import qualified Network.HTTP.Client as HttpClient
import qualified Network.HTTP.Client.TLS as HttpClientTls
import qualified PgenieCli.Config.Model as Config
import qualified PgenieCli.Config.Parsing as Parsing
import PgenieCli.Prelude
import qualified PgenieService as Client

run :: IO ()
run = runProcess $ do
  migrations <- readMigrations
  error "TODO"

runProcess :: Process a -> IO a
runProcess process = do
  config <- Parsing.fileInDir mempty
  clientConfig <- Client.newConfig
  manager <- HttpClientTls.newTlsManager
  res <- runExceptT $ runReaderT process (config, manager, clientConfig)
  either (die . printBroadAs) return res

-- * Helpers

type Process =
  ReaderT Env (ExceptT Error IO)

type Env =
  (Config.Project, HttpClient.Manager, Client.PgenieServiceConfig)

data Error
  = MimeError !Client.MimeError

instance BroadPrinting Error where
  toBroadBuilder =
    error "TODO"

runClientRequest ::
  (Client.Produces req accept, Client.MimeUnrender accept res, Client.MimeType contentType) =>
  Client.PgenieServiceRequest req contentType res accept ->
  Process res
runClientRequest req =
  ReaderT $ \(_, manager, clientConfig) ->
    ExceptT $ fmap (first MimeError) $ Client.dispatchMime' manager clientConfig req

readMigrations :: Process [(Text, Text)]
readMigrations =
  error "TODO"

publish :: Client.CodegenPostRequest -> Process [Client.CodegenPost200ResponseInner]
publish req =
  runClientRequest $ Client.codegenPost req

write :: [Client.CodegenPost200ResponseInner] -> Process ()
write =
  error "TODO"
