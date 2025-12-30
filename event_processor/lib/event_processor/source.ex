defmodule EventProcessor.Source do
  use GenServer

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def get_unackeds(pid) do
    GenServer.call(pid, :getunacked)
  end

  def ack(pid, id) do
    GenServer.cast(pid, {:ack, id})
  end

  @impl true
  def init(default) do
    {:ok, {1, default, []}}
  end

  @impl true
  def handle_call(:get, _from, {current_id, [head | tail], unacked}) do
    {:reply, %EventProcessor.Event{id: current_id, payload: head},
     {current_id + 1, tail, [current_id | unacked]}}
  end

  @impl true
  def handle_call(:getunacked, _from, {current_id, pendings, unacked}) do
    {:reply, unacked, {current_id, pendings, unacked}}
  end

  @impl true
  def handle_cast({:ack, id}, {current_id, pendings, unackeds}) do
    new_unackeds = Enum.filter(unackeds, fn unacked_id -> unacked_id != id end)
    {:noreply, {current_id, pendings, new_unackeds}}
  end
end
