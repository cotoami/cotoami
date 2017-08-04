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

  defmodule NotFound do
    @moduledoc """
    raised when the requested entity is not found.
    """

    defexception [:message, plug_status: 404]

    def exception(target) do
      %NotFound{message: "Not found: #{target}"}
    end
  end
end
