App.results = App.cable.subscriptions.create "ResultsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    tr = $("#pool_#{data.game_id}")
    if (data.game && !data.game.blank?)
      $("#modal-window").modal("hide")
      tr.children(':not(:first-child)').remove()
      tr.append data.game
      if (data.playoffs)
        $("#playoffs_finished").click()
      else
        $("#poolplay_finished").click()

# $(document).on 'turbolinks:load', ->
#   submit_score()
#
# submit_score = () ->
#   $("#modal_button").on 'click', (event) ->
#     event.preventDefault()
#     $(this).siblings(".score_input").value = ""
