defmodule Overlay do
  @moduledoc """
  Overlay keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger

  def get_file_stats(dir) do
    diff_files =
      case System.cmd("git", [
             "--git-dir=#{dir}/.git",
             "--work-tree=#{dir}",
             "diff",
             "--numstat",
             "HEAD"
           ]) do
        {data, 0} ->
          data
          |> String.split()
          |> Enum.chunk_every(3)
          |> Enum.map(fn [added, removed, filepath] ->
            {filepath, %{added: added, removed: removed}}
          end)

        error ->
          Logger.error("Command diff failed: #{inspect(error)}")
          []
      end

    untracked_files =
      case System.cmd("git", [
             "--git-dir=#{dir}/.git",
             "--work-tree=#{dir}",
             "ls-files",
             "--others",
             "--exclude-standard"
           ]) do
        {data, 0} ->
          data
          |> String.split()
          |> Enum.map(fn filepath ->
            path = Path.join(dir, filepath)

            lines =
              path
              |> File.stream!()
              |> Enum.count()

            {filepath, %{added: lines, removed: 0}}
          end)

        error ->
          Logger.error("Command ls-files failed: #{inspect(error)}")
          []
      end

    Map.new(diff_files ++ untracked_files)
  end
end
