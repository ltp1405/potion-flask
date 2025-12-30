defmodule EventProcessor do
  @moduledoc """
  Documentation for `EventProcessor`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> EventProcessor.hello()
      :world

  """
  def hello do
    :world
  end

  def test_event do
    {:ok, sv} = GenServer.start_link(EventProcessor.Source, ["hello", "123"])

    {:ok, p} =
      GenServer.start_link(EventProcessor.Processor, {sv, fn event -> String.upcase(event) end})

    {:ok, p2} =
      GenServer.start_link(
        EventProcessor.Processor,
        {p, fn event -> String.duplicate(event, 2) end}
      )

    # EventProcessor.Processor.get(p2)
    # EventProcessor.Processor.get(p2)

    {:ok, sink} = GenServer.start_link(EventProcessor.Sink, p2)
    EventProcessor.Sink.get(sink)
    EventProcessor.Sink.get(sink)
    EventProcessor.Sink.get(sink)

    # EventProcessor.Source.get(sv)
    # EventProcessor.Source.get(sv)
    # EventProcessor.Source.get_unackeds(sv)
    # EventProcessor.Source.ack(sv, 2)
    # EventProcessor.Source.get_unackeds(sv)
  end
end
