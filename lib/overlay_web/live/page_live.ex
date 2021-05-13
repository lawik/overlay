defmodule OverlayWeb.PageLive do
  use OverlayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Overlay.PubSub, "stats")
    Overlay.Filewatch.stat()
    {:ok, assign(socket, stats: [])}
  end

  @impl true
  def handle_info({:loc_stats, stats}, socket) do
    {:noreply, assign(socket, stats: stats)}
  end
end
