# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

fullCalendar = ->
  $('#calendar').fullCalendar
    editable: false
    selectable: true
    droppable: true
    timezone: 'Tokyo'
    timeFormat:
      month: 'HH:mm'
      week: 'HH:mm'
      day: 'HH:mm'
    events: '/events.json'

    eventClick:
      (calEvent) ->
        document.location = "../events/#{calEvent.id}/edit"

    select:
      (start, end, allDay) ->
        starttime = moment(start).format("YYYY/MM/DD H:mm")
        endtime = moment(end).format("YYYY/MM/DD H:mm")
        $('#createEventModal #eventStartTime').val(starttime)
        $('#createEventModal #eventEndTime').val(endtime)
        $('#createEventModal #eventAllDay').val(allDay)
        $('#createEventModal').modal("show")

    drop:
      (date) ->
        duration = $(this).data('event').duration
        origin_dtstart = new Date($(this).data('event').dtstart)
        dtstart = new Date(date)
        dtstart = moment(dtstart).hour(moment(origin_dtstart).hour())
        dtstart = moment(dtstart).minute(moment(origin_dtstart).minute())
        dtend = moment(dtstart).add(duration,'seconds')
        data = {
          event:
            summary: $(this).data('event').title
            dtstart: new Date(dtstart)
            dtend: new Date(dtend)
            origin_event_id: $(this).data('event').id
        }

        $ . ajax
          type: 'POST'
          url: '/events/ajax_create_event_from_old_event'
          data: data
          timeout: 9000
          success: ->
          error: ->
            alert "error"

    eventAfterAllRender:
      (view) ->
        target_id = "#start" + view.intervalStart.clone().subtract(1,'years').format("YYYYMM")
        scrollOldEvents(target_id)
        $('#calendar').droppable
          tolerance: 'pointer'

scrollOldEvents = (target)->
  current_top = $('#external-events').scrollTop()
  point_date_top = $(target).position().top
  scroll_top = point_date_top + current_top

  console.log("current_top: #{current_top}")
  console.log("point_date_top: #{point_date_top}")
  console.log("scroll_top: #{scroll_top}")

  $('#external-events').scrollTop(scroll_top)

doSubmit = ->
  $('#submitButton').on 'click', (e) ->
    e.preventDefault()
    $("#createEventModal").modal('hide')
    console.log($('#eventSummary').val())
    console.log($('#eventStartTime').val())
    console.log($('#eventEndTime').val())
    console.log($('#eventAllDay').val())

    data = {
      event:
        summary: $('#eventSummary').val()
        dtstart: new Date($('#eventStartTime').val())
        dtend: new Date($('#eventEndTime').val())
    }

    $ . ajax
      type: 'POST'
      url: '/events'
      data: data
      timeout: 9000
      success: ->
        $("#calendar").fullCalendar('renderEvent',
        {
           title: $('#eventSummary').val()
           start: new Date($('#eventStartTime').val())
           end: new Date($('#eventEndTime').val())
           allDay: ($('#eventAllDay').val() == "true")
        },
        true)
      error: ->
        alert "error"

initDraggableOldEvent = ->
  $('.fc-event').each ->
    event = {
      id: $(this).attr("id")
      title: $.trim($(this).text()).match(/.*/).toString()
      dtstart: $(this).attr("dtstart")
      duration: $(this).attr("duration")
      color: "#9FC6E7"
      textColor: "#000000"
    }

    $(this).data('event', event)

    $(this).draggable
      appendTo: "body"
      zIndex: 999
      revert: "invalid"
      helper: "clone"

ready = ->
  fullCalendar()
  doSubmit()
  initDraggableOldEvent()

  $('.open-side-menu').click ->
    if ($('.side-menu.calendar').is(':visible') == true)
      $('.side-menu.calendar').hide(200, ->
        $('#calendar').css('width','100%')
        )
    else
      $('.side-menu.calendar').show(200, ->
        view = $('#calendar').fullCalendar('getView')
        target_id = "#start" + view.intervalStart.clone().subtract(1,'years').format("YYYYMM")
        scrollOldEvents(target_id)
        )
      $('#calendar').css('width','80%')

  $('#eventStartTime').datetimepicker
    format: "YYYY/MM/DD H:mm"
    icons:
      time: "fa fa-clock-o"
      date: "fa fa-calendar"
      up: "fa fa-chevron-up"
      down: "fa fa-chevron-down"
      previous: "fa fa-chevron-left"
      next: "fa fa-chevron-right"

  $('#eventEndTime').datetimepicker
    format: "YYYY/MM/DD H:mm"
    icons:
      time: "fa fa-clock-o"
      date: "fa fa-calendar"
      up: "fa fa-chevron-up"
      down: "fa fa-chevron-down"
      previous: "fa fa-chevron-left"
      next: "fa fa-chevron-right"

  $('#myTab a:last').tab('show')

$(document).ready(ready)
$(document).on('page:load', ready)
