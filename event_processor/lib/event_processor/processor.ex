defmodule EventProcessor.Processor do
  use GenServer

  def start_link({prev_stage, mapper}) do
    GenServer.start_link(__MODULE__, {prev_stage, mapper})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  @impl true
  def init({prev_stage, mapper}) do
    {:ok, {prev_stage, mapper}}
  end

  @impl true
  def handle_cast({:ack, id}, state) do
    {prev_stage, _} = state
    GenServer.cast(prev_stage, {:ack, id})
    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, {prev_stage, mapper}) do
    %EventProcessor.Event{id: id, payload: payload} = GenServer.call(prev_stage, :get)
    processed = case mapper.(payload) do
       {:ok, new_payload} -> new_payload
       {:error, e} -> {:error, e}
       new_payload -> {:ok, new_payload}
    end
    case processed do
      {:ok, _} -> GenServer.cast(prev_stage, {:ack, id})
      {:error, _} -> GenServer.cast(prev_stage, {:nack, id})
    end
    {:reply, %EventProcessor.Event{id: id, payload: mapper.(payload)}, {prev_stage, mapper}}
  end

end
