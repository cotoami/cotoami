defmodule Cotoami.Helpers do
  def and_then(value, function) when is_function(function) do
    function.(value)
  end
end
