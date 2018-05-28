defmodule CotoamiWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Cotoami.Web, :controller
      use Cotoami.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: CotoamiWeb

      alias Cotoami.Repo
      import Ecto
      import Ecto.Query

      import CotoamiWeb.Router.Helpers
      import CotoamiWeb.Gettext
      import CotoamiWeb.ControllerHelpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/cotoami_web/templates",
                        namespace: CotoamiWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import CotoamiWeb.Router.Helpers
      import CotoamiWeb.ErrorHelpers
      import CotoamiWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import CotoamiWeb.AuthPlug, only: [require_auth: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Cotoami.Repo
      import Ecto
      import Ecto.Query
      import CotoamiWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
