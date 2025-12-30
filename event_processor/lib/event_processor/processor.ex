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
  def handle_call(:get, _from, {prev_stage, mapper}) do
    %EventProcessor.Event{id: id, payload: payload} = GenServer.call(prev_stage, :get)
    processed = case mapper(payload) do
       {:ok, new_payload} -> do:
        GenServer.call()
        new_payload
      end
       new_payload -> new_payload
    end
    {:reply, %EventProcessor.Event{id: id, payload: mapper.(payload)}, {prev_stage, mapper}}
  end

end
