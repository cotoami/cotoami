defmodule Cotoami.Exceptions do
  @moduledoc """
  Exceptions
  """

  # credo:disable-for-next-line Credo.Check.Consistency.ExceptionNames
  defmodule NoPermission do
    @moduledoc """
    raised when the amishi has no permission for the operation
    """
    defexception [
      message: "You have no permission to do this operation.",
      plug_status: 403
    ]
  end

  # credo:disable-for-next-line Credo.Check.Consistency.ExceptionNames
  defmodule NotFound do
    @moduledoc """
    raised when the requested entity is not found.
    """
    defexception [:message, plug_status: 404]

    def exception(target) do
      %NotFound{message: "Not found: #{target}"}
    end
  end

  # credo:disable-for-next-line Credo.Check.Consistency.ExceptionNames
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
