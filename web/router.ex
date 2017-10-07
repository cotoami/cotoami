defmodule Cotoami.Router do
  use Cotoami.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug Cotoami.Language, "en_US"
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cotoami.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Cotoami.Language, "en_US"
    plug :fetch_session
    plug :put_secure_browser_headers
    plug Cotoami.ApiCsrfProtection
    plug Cotoami.Auth
  end

  @clientside_paths [
    "/",
    "/cotonomas/:key"
  ]

  scope "/", Cotoami do
    pipe_through :browser

    Enum.each(@clientside_paths, &get(&1, PageController, :index))
    get "/signin/:token", SigninController, :signin
    get "/signout", SessionController, :signout

  end

  scope "/export", Cotoami do
    pipe_through [:browser, :require_auth]

    get "/", DatabaseController, :export
  end

  scope "/api/public", Cotoami do
    pipe_through :api

    get "/", PublicController, :index
    get "/info", PublicController, :info
    get "/session", SessionController, :index
    get "/signin/request/:email", SigninController, :request
  end

  scope "/api", Cotoami do
    pipe_through [:api, :require_auth]

    post "/import", DatabaseController, :import
    get "/invite/:email", AmishiController, :invite
    get "/amishis/email/:email", AmishiController, :show_by_email
    resources "/cotos", CotoController, only: [:index, :create, :update, :delete]
    resources "/cotonomas", CotonomaController, only: [:index, :create]
    get "/cotonomas/:key/cotos", CotonomaController, :cotos
    get "/graph", CotoGraphController, :index
    get "/graph/:cotonoma_key", CotoGraphController, :index
    get "/graph/subgraph/:cotonoma_key", CotoGraphController, :subgraph
    put "/graph/pin", CotoGraphController, :pin
    delete "/graph/pin/:coto_id", CotoGraphController, :unpin
    put "/graph/:cotonoma_key/pin", CotoGraphController, :pin
    delete "/graph/:cotonoma_key/pin/:coto_id", CotoGraphController, :unpin
    put "/graph/connection/:start_id", CotoGraphController, :connect
    put "/graph/:cotonoma_key/connection/:start_id", CotoGraphController, :connect
    delete "/graph/connection/:start_id/:end_id", CotoGraphController, :disconnect
    delete "/graph/:cotonoma_key/connection/:start_id/:end_id", CotoGraphController, :disconnect
  end
end
