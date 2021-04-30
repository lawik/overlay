defmodule OverlayWeb.PageLive do
  use OverlayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    stats = Overlay.get_file_stats(File.cwd!())
    Phoenix.PubSub.subscribe(Overlay.PubSub, "stats")
    {:ok, assign(socket, stats: stats)}
  end

  @impl true
  def handle_info({:loc_stats, stats}, socket) do
    {:noreply, assign(socket, stats: stats)}
  end
end
