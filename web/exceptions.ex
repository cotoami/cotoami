defmodule Cotoami.Exceptions do

  defmodule UnsupportedOperation do
    defexception [
      message: "This operation is not supported.",
      plug_status: 405
    ]
  end
end
