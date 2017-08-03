defmodule Cotoami.Exceptions do
  @moduledoc """
  Exceptions
  """

  defmodule InvalidOperation do
    @moduledoc """
    raised when an invalid operation has been requested.
    """
    defexception [
      message: "This operation is not supported.",
      plug_status: 405
    ]
  end
end
