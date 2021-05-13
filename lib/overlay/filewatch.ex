defmodule Overlay.Filewatch do
  use GenServer
  require Logger

  def start_link(opts) do
    {dir, opts} = Keyword.pop(opts, :dir)
    GenServer.start_link(__MODULE__, dir, opts)
  end

  def init(dir) do
    path = Path.absname(dir)
    {:ok, pid} = FileSystem.start_link(dirs: [path])
    Phoenix.PubSub.subscribe(Overlay.PubSub, "watcher")

    state = %{
      dir: path,
      watcher: pid,
      processed_at: inc(),
      latest: inc(),
      changestamps: %{},
      stats: []
    }

    state = Map.put(state, :stats, update_stats(state))

    FileSystem.subscribe(pid)
    Logger.info("Watching #{path}")
    {:ok, state}
  end

  def stat do
    Phoenix.PubSub.broadcast!(Overlay.PubSub, "watcher", :stat)
  end

  def handle_info(:stat, state) do
    stats = update_stats(state)
    {:noreply, %{state | stats: stats, processed_at: inc()}}
  end

  def handle_info({:file_event, _, {path, [:created]}}, state), do: changestamp(path, state)

  def handle_info({:file_event, _, {path, [:modified, :closed]}}, state),
    do: changestamp(path, state)

  def handle_info({:file_event, _, {path, [:deleted]}}, state), do: changestamp(path, state)

  def handle_info({:file_event, _, {_path, _stuff}}, state) do
    {:noreply, state}
  end

  def handle_info(:process, state) do
    if state.processed_at < state.latest do
      stats = update_stats(state)
      {:noreply, %{state | stats: stats, processed_at: inc()}}
    else
      {:noreply, state}
    end
  end

  defp changestamp(path, %{changestamps: cs} = state) do
    latest = inc()
    cs = Map.put(cs, path, latest)
    Process.send_after(self(), :process, 100)
    {:noreply, %{state | changestamps: cs, latest: latest}}
  end

  defp update_stats(state) do
    stats =
      state.dir
      |> Overlay.get_file_stats()
      |> Enum.sort_by(
        fn {ka, _va} ->
          path = Path.join(state.dir, ka)
          %{mtime: mtime} = File.stat!(path)
          mtime
        end,
        :desc
      )

    Logger.info("Stats: #{inspect(stats)}")
    Phoenix.PubSub.broadcast!(Overlay.PubSub, "stats", {:loc_stats, stats})
    stats
  end

  defp inc do
    System.unique_integer([:positive, :monotonic])
  end
end
