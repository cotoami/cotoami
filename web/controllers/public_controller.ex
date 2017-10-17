defmodule Cotoami.PublicController do
  use Cotoami.Web, :controller
  require Logger

  plug Logster.Plugs.ChangeLogLevel, to: :debug

  def index(conn, _params) do
    text conn, "≡≡≡≡≡≡≡≡≡≡c⌒っﾟДﾟ)っ ｽﾞｻｰｯ!!"
  end
end
