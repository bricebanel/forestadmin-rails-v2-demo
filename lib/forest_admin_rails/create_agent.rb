module ForestAdminRails
  class CreateAgent
    include ForestAdminDatasourceCustomizer::Decorators::Action::Types
    include ForestAdminDatasourceCustomizer::Decorators::Action

    def self.setup!
      database_configuration = Rails.configuration.database_configuration
      datasource = ForestAdminDatasourceActiveRecord::Datasource.new(database_configuration[Rails.env])

      @create_agent = ForestAdminAgent::Builder::AgentFactory.instance.add_datasource(datasource)
      customize
      @create_agent.build
    end

    def self.customize
      # Add "Approve Onboarding" smart action to Company collection
      @create_agent.customize_collection('Company') do |collection|
        collection.add_action(
          'Approve Onboarding',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Approve company onboarding and activate their account",
            submit_button_label: "✅ Approve & Activate",
            form: [
              {
                type: FieldType::NUMBER,
                label: "Approved Credit Limit (€)",
                id: "approved_credit_limit",
                description: "Set the credit limit for this company",
                is_required: true
              },
              {
                type: FieldType::STRING,
                label: "Justification Notes",
                id: "justification",
                description: "Explain why this credit limit was approved",
                is_required: true,
                widget: 'TextArea'
              },
              {
                type: FieldType::BOOLEAN,
                label: "Enable Factoring Service",
                id: "enable_factoring",
                description: "Allow this company to use invoice factoring",
                value: true
              },
              {
                type: FieldType::BOOLEAN,
                label: "Enable Guarantees Service",
                id: "enable_guarantees",
                description: "Allow this company to request retention guarantees",
                value: true
              }
            ]
          ) do |context, result_builder|
            # Execute block - this is where the action logic happens
            # Use get_record to fetch the company data (Forest Admin's recommended approach)
            # This handles ID type conversion internally
            company_record = context.get_record(['id', 'company_name', 'kyc_status', 'status', 'credit_limit_eur', 'onboarded_at'])

            # Get the ActiveRecord model instance for database operations
            company = Company.find(company_record['id'])

            # Validate company state
            unless ['pending', 'in_progress'].include?(company.kyc_status)
              next result_builder.error(message: "❌ Cannot approve: Company KYC status is '#{company.kyc_status}'. Only 'pending' or 'in_progress' companies can be approved.")
            end

            # Get form values
            approved_limit = context.get_form_value('approved_credit_limit')
            justification = context.get_form_value('justification')
            enable_factoring = context.get_form_value('enable_factoring')
            enable_guarantees = context.get_form_value('enable_guarantees')

            # Update company
            company.update!(
              kyc_status: 'validated',
              status: 'active',
              credit_limit_eur: approved_limit,
              onboarded_at: company.onboarded_at || Time.current
            )

            # Log the action (you could add this to a separate audit log table)
            Rails.logger.info("Company approved: #{company.company_name} (ID: #{company.id}) - Credit limit: €#{approved_limit} - Justification: #{justification} - Factoring: #{enable_factoring}, Guarantees: #{enable_guarantees}")

            # Return success message
            result_builder.success(
              message: "✅ #{company.company_name} has been approved and activated!\n\n" \
              "Credit Limit: €#{approved_limit.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}\n" \
              "Services: #{[enable_factoring ? 'Factoring' : nil, enable_guarantees ? 'Guarantees' : nil].compact.join(', ')}\n\n" \
              "The company can now start using Faktus services."
            )
          end
        )

        # Add "Reject Onboarding" smart action to Company collection
        collection.add_action(
          'Reject Onboarding',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Reject company onboarding and suspend their account",
            submit_button_label: "❌ Deny Onboarding",
            form: [
              {
                type: FieldType::STRING,
                label: "Rejection Reason",
                id: "rejection_reason",
                description: "Explain why this company's onboarding is being rejected",
                is_required: true,
                widget: 'TextArea'
              },
              {
                type: FieldType::BOOLEAN,
                label: "Send notification email to company",
                id: "send_notification",
                description: "Notify the company about the rejection via email",
                value: true
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the company data from Forest Admin
            company_record = context.get_record(['id', 'company_name', 'kyc_status', 'status'])

            # 2. Get the ActiveRecord model instance
            company = Company.find(company_record['id'])

            # 3. Get form values
            rejection_reason = context.get_form_value('rejection_reason')
            send_notification = context.get_form_value('send_notification')

            # 4. Update company status
            company.update!(
              kyc_status: 'rejected',
              status: 'suspended'
            )

            # 5. Log the rejection action
            Rails.logger.info(
              "Company onboarding rejected: #{company.company_name} (ID: #{company.id}) - " \
              "Reason: #{rejection_reason} - Send notification: #{send_notification}"
            )

            # 6. Return success message
            notification_status = send_notification ? "📧 Email notification will be sent to the company." : "No notification will be sent."

            result_builder.success(
              message: "❌ #{company.company_name}'s onboarding has been rejected.\n\n" \
                       "Status: Suspended\n" \
                       "Reason: #{rejection_reason}\n\n" \
                       "#{notification_status}"
            )
          end
        )
      end
    end
  end
end
