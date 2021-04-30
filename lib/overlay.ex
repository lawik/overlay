defmodule Overlay do
  @moduledoc """
  Overlay keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  def get_file_stats(dir) do
    case System.cmd("git", ["diff", "--numstat", "HEAD", "#{dir}"]) do
      {data, 0} ->
        data
        |> String.split()
        |> Enum.chunk_every(3)
        |> Enum.map(fn [added, removed, filepath] ->
          {filepath, %{added: added, removed: removed}}
        end)
        |> Map.new()

      error ->
        Logger.error("Command failed: #{inspect(error)}")
        %{}
    end
  end

  # comment
end
