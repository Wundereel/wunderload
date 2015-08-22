class VisitorsController < ApplicationController
  layout 'bare', only: [:job_start, :email_signup]
end
