defmodule Cotoami.Exceptions do
  @moduledoc """
  Exceptions
  """

  defmodule NoPermission do
    @moduledoc """
    raised when the amishi has no permission for the operation
    """
    defexception message: "You have no permission to do this operation.",
                 plug_status: 403
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

  defmodule InvalidOperation do
    @moduledoc """
    raised when an invalid operation has been requested.
    """
    defexception message: "This operation is not supported.",
                 plug_status: 405
  end

  defmodule DuplicateRepost do
    @moduledoc """
    raised when reposting a coto that has already been posted in the cotonoma
    """
    defexception message: "This coto has already been posted in the cotonoma",
                 plug_status: 405
  end
end
