defmodule Cotoami.PublicController do
  use Cotoami.Web, :controller
  require Logger
  
  def index(conn, _params) do
    text conn, "≡≡≡≡≡≡≡≡≡≡c⌒っﾟДﾟ)っ ｽﾞｻｰｯ!!"
  end
  
  def info(conn, _params) do
    {:ok, hostname} = :inet.gethostname
    json conn, %{
      hostname: to_string hostname
    }
  end
end
