RailsAdmin.config do |config|
  config.parent_controller = '::AdminController'

  config.authorize_with do
    redirect_to main_app.root_path unless current_user.admin?
  end

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  PAPER_TRAIL_AUDIT_MODEL = %w(Streamer).freeze

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    history_index do
      only PAPER_TRAIL_AUDIT_MODEL
    end
    history_show do
      only PAPER_TRAIL_AUDIT_MODEL
    end
    new
    export
    bulk_delete
    show
    edit
    delete do
      controller do
        proc do
          if request.get? # DELETE

            respond_to do |format|
              format.html { render @action.template_name }
              format.js   { render @action.template_name, layout: false }
            end

          elsif request.delete? # DESTROY

            redirect_path = nil
            @auditing_adapter && @auditing_adapter.delete_object(@object, @abstract_model, _current_user)
            if @object.destroy
              flash[:success] = t('admin.flash.successful',
                name: @model_config.label, action: t('admin.actions.delete.done'))
              redirect_path = '/api' + index_path
            else
              flash[:error] = t('admin.flash.error',
                name: @model_config.label, action: t('admin.actions.delete.done'))
              redirect_path = '/api' + back_or_index
            end

            redirect_to redirect_path

          end
        end
      end
    end
    show_in_app

  end
end
