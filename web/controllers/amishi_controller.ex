defmodule Cotoami.AmishiController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.AmishiService
  
  def show_by_email(conn, %{"email" => email}) do
    case AmishiService.get_by_email(email) do
      nil -> 
        send_resp(conn, :not_found, "")
      amishi ->
        render(conn, "amishi.json", 
          amishi: AmishiService.append_gravatar_profile(amishi)
        )
    end
  end
end
