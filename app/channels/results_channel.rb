class ResultsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "results_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
