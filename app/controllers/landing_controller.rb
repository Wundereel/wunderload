class LandingController < ApplicationController
  include HighVoltage::StaticPage

  layout 'bare'

  def page_finder_factory
    HighVoltage::PageFinder
  end
end
