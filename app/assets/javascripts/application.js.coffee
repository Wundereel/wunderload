# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require sortable/js/sortable.js
#= require chosen-jquery
#= require_tree .

$ ->
  $('.chosen-select').chosen
    disable_search_threshold: 15
    allow_single_deselect: true


$(document).ready ->
  $(document).on "ajax:success", "form.new_interested_person", (event, xhr, settings) ->
    if $(this).data('successUrl')
      window.location =  $(this).data('successUrl')
    else if $(this).data('successelement')
      $(this).addClass('hidden')
      $("##{$(this).data('successelement')}").removeClass('hidden')


  $(document).on "ajax:error", "form.new_interested_person", (event, jqxhr, settings, exception) ->
    $(this)
      .find('.form-group.interested_person_email .control-error-label')
      .text("Email #{jqxhr.responseJSON.email[0]}")

    $(this)
      .find('.form-group.interested_person_email')
      .addClass('has-error')


  $('.popup-youtube, .popup-vimeo, .popup-gmaps').magnificPopup(
    disableOn: 700,
    type: 'iframe',
    mainClass: 'mfp-fade',
    removalDelay: 160,
    preloader: false,

    fixedContentPos: false
  )
