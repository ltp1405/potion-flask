defmodule EventProcessor.Sink do
  use GenServer

  def start_link(prev_stage) do
    GenServer.start_link(__MODULE__, prev_stage)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  @impl true
  def init(prev_stage) do
    {:ok, prev_stage}
  end

  @impl true
  def handle_call(:get, _from, prev_stage) do
    val = GenServer.call(prev_stage, :get)
    {:reply, val, prev_stage}
  end
end
