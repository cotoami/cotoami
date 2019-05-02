defmodule CotoamiWeb.Router do
  use CotoamiWeb, :router
  alias CotoamiWeb.LanguagePlug
  alias CotoamiWeb.ApiCsrfProtectionPlug
  alias CotoamiWeb.AuthPlug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(LanguagePlug, "en_US")
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(AuthPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(LanguagePlug, "en_US")
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
    plug(ApiCsrfProtectionPlug)
    plug(AuthPlug)
  end

  @clientside_paths [
    "/",
    "/cotonomas/:key"
  ]

  scope "/", CotoamiWeb do
    pipe_through(:browser)

    Enum.each(@clientside_paths, &get(&1, PageController, :index))
    get("/signin/:token", EmailAuthController, :signin)
    get("/join/:token", EmailAuthController, :accept_invite)
    get("/signout", SessionController, :signout)
  end

  scope "/auth", CotoamiWeb do
    pipe_through(:browser)
    get("/:provider", OAuth2Controller, :index)
    get("/:provider/callback", OAuth2Controller, :callback)
  end

  scope "/export", CotoamiWeb do
    pipe_through([:browser, :require_auth])

    get("/", DatabaseController, :export)
  end

  scope "/api/public", CotoamiWeb do
    pipe_through(:api)

    get("/", PublicController, :index)
    get("/session", SessionController, :index)
    get("/signin/request/:email", EmailAuthController, :request)
  end

  scope "/api", CotoamiWeb do
    pipe_through([:api, :require_auth])

    post("/import", DatabaseController, :import)

    get("/invite/:email", AmishiController, :invite)
    get("/invitees", AmishiController, :invitees)
    get("/amishis/email/refresh", AmishiController, :refresh_email_user_data)
    get("/amishis/email/:email", AmishiController, :show_by_email)
    get("/amishis/:id", AmishiController, :show)

    get("/search/:query", CotoController, :search)
    resources("/cotos", CotoController, only: [:index, :create, :update, :delete])
    get("/cotos/random", CotoController, :random)
    put("/cotos/:id/cotonomatize", CotoController, :cotonomatize)

    resources("/cotonomas", CotonomaController, only: [:index, :create])
    get("/cotonomas/:cotonoma_id/cotonomas", CotonomaController, :sub)
    get("/cotonomas/:key/cotos", CotonomaController, :cotos)
    get("/cotonomas/:key/cotos/random", CotonomaController, :random)
    get("/cotonomas/:key/stats", CotonomaController, :stats)

    get("/watchlist", WatchController, :index)
    put("/watchlist/:cotonoma_key", WatchController, :create)
    patch("/watchlist/:cotonoma_key", WatchController, :update)
    delete("/watchlist/:cotonoma_key", WatchController, :delete)

    get("/graph", CotoGraphController, :index)
    get("/graph/:cotonoma_key", CotoGraphController, :index)
    get("/graph/subgraph/:cotonoma_key", CotoGraphController, :subgraph)
    put("/graph/pin", CotoGraphController, :pin)
    delete("/graph/pin/:coto_id", CotoGraphController, :unpin)
    put("/graph/:cotonoma_key/pin", CotoGraphController, :pin)
    delete("/graph/:cotonoma_key/pin/:coto_id", CotoGraphController, :unpin)
    put("/graph/connections/:start_id", CotoGraphController, :connect)
    put("/graph/:cotonoma_key/connections/:start_id", CotoGraphController, :connect)
    put("/graph/reorder", CotoGraphController, :reorder)
    put("/graph/:cotonoma_key/reorder", CotoGraphController, :reorder)
    put("/graph/connections/:start_id/reorder", CotoGraphController, :reorder)
    put("/graph/connections/:start_id/:end_id", CotoGraphController, :update_connection)
    delete("/graph/connections/:start_id/:end_id", CotoGraphController, :disconnect)
  end
end
