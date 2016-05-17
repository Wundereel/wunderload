class LandingController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  def layout_for_page
    case params[:id]
    when 'questions'
      false
    else
      'bare'
    end
  end

  def page_finder_factory
    HighVoltage::PageFinder
  end
end
