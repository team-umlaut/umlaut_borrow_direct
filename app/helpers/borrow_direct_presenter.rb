# Rails helpers make it hard to isolate things, we wrap up the helpers
# for our BD resolve section in this helper presenter class. 
#
# Where `renderer' is the SectionRenderer object probably available in
# view as 'renderer'
# bd_presenter = BorrowDirectPresenter.new(renderer)
class BorrowDirectPresenter
  attr_reader :request, :responses, :renderer
  def initialize(renderer)
    @renderer = renderer
    @request = renderer.request
    @responses = renderer.responses_list
  end

  # nil or a ServiceResponse with type bd_request_status
  def status_response
    unless defined? @status_response
      @status_response = responses.find {|r| r.service_type_value_name == "bd_request_status"}
    end
    return @status_response
  end

  # nil or a ServiceResponse of type bd_request_prompt
  def request_prompt_response
    unless defined? @request_prompt_response
      @request_prompt_response = responses.find {|r| r.service_type_value_name == "bd_request_prompt"}
    end
    return @request_prompt_response
  end

  # nil or a ServiceResponse of type bd_link_to_search
  def link_response
    unless defined? @link_response
      @link_response = responses.find {|r| r.service_type_value_name == "bd_link_to_search"  }
    end
    return @link_response
  end

  # nil or a ServiceResponse of type bd_not_available
  def not_available_response
    unless defined? @not_available_response
      @not_available_response = responses.find {|r| r.service_type_value_name == "bd_not_available" }
    end
    return @not_available_response
  end

  def request_submission_in_progress?
    self.status_response && (self.status_response.view_data[:status] == BorrowDirectController::InProgress)
  end

  def service_in_progress?
    request.service_types_in_progress?(renderer.service_type_values)
  end

  # use our custom 'request being placed' message when appropriate
  def spinner_render_hash
    render_hash = renderer.spinner_render_hash
    render_hash[:locals][:progress_message] = I18n.t("umlaut.services.borrow_direct_adaptor.bd_request_status.progress") if self.request_submission_in_progress?
    return render_hash
  end

  def show_request_form?
    (! self.status_response) && self.request_prompt_response
  end

  def show_not_available?
    (! self.status_response) && (! show_request_form? ) && self.not_available_response
  end

  def show_link_response?
    (! self.show_request_form?) && (! self.show_not_available?) && self.link_response
  end

end