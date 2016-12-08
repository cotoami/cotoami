defmodule Cotoami.Router do
  use Cotoami.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Cotoami.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Cotoami.Auth
  end

  scope "/", Cotoami do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Cotoami do
    pipe_through :api
    
    resources "/cotos", CotoController, only: [:index, :create]
  end
end
