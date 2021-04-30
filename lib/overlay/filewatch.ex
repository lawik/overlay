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

    stats = Overlay.get_file_stats(path)

    state = %{
      dir: path,
      watcher: pid,
      stats: stats
    }

    FileSystem.subscribe(pid)
    Logger.info("Watching #{path}")
    {:ok, state}
  end

  def handle_info({:file_event, _, {_path, _stuff}}, state) do
    # Logger.info("File change: #{path}")
    stats = Overlay.get_file_stats(state.dir)

    state =
      if stats != state.stats do
        Logger.info("Stats: #{inspect(stats)}")
        Phoenix.PubSub.broadcast!(Overlay.PubSub, "stats", {:loc_stats, stats})
        %{state | stats: stats}
      else
        state
      end

    {:noreply, state}
  end
end
