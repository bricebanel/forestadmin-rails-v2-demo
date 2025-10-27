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
            unless ['pending', 'escalated', 'waiting_on_customer'].include?(company.kyc_status)
              next result_builder.error(message: "❌ Cannot approve: Company KYC status is '#{company.kyc_status}'. Only 'pending', 'escalated', or 'waiting_on_customer' companies can be approved.")
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

            # Build HTML success modal
            formatted_credit_limit = approved_limit.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
            services_list = [
              enable_factoring ? '✓ Invoice Factoring' : '✗ Invoice Factoring',
              enable_guarantees ? '✓ Retention Guarantees' : '✗ Retention Guarantees'
            ]

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #2c3e50; font-size: 20px;'>
                ✅ Company Approved and Activated
              </h3>

              <p style='margin: 15px 0; color: #333; font-size: 14px;'>
                <strong style='font-size: 16px; color: #2c3e50;'>#{company.company_name}</strong> has been successfully approved and activated.
              </p>

              <div style='margin: 20px 0; padding: 15px; background-color: #f5f5f5; border-radius: 6px;'>
                <p style='margin: 0 0 10px 0; color: #666; font-size: 13px; font-weight: 600; text-transform: uppercase;'>Credit Limit</p>
                <p style='margin: 0; color: #2c3e50; font-size: 24px; font-weight: 600;'>€#{formatted_credit_limit}</p>
              </div>

              <div style='margin: 20px 0;'>
                <p style='margin: 0 0 10px 0; color: #666; font-size: 13px; font-weight: 600; text-transform: uppercase;'>Services Enabled</p>
                <ul style='margin: 0; padding-left: 0; list-style: none;'>
                  <li style='margin: 5px 0; color: #333; font-size: 14px;'>#{services_list[0]}</li>
                  <li style='margin: 5px 0; color: #333; font-size: 14px;'>#{services_list[1]}</li>
                </ul>
              </div>

              <div style='margin: 20px 0; padding: 12px; background-color: #e3f2fd; border-left: 3px solid #2196f3; border-radius: 4px;'>
                <p style='margin: 0; font-weight: 600; color: #1565c0; font-size: 13px;'>Justification:</p>
                <p style='margin: 8px 0 0 0; color: #333; font-size: 14px;'>#{justification}</p>
              </div>

              <div style='margin-top: 20px; padding: 15px; background-color: #e8f5e9; border-left: 4px solid #4caf50; border-radius: 4px;'>
                <p style='margin: 0; color: #2e7d32; font-size: 14px;'>
                  🎉 <strong>#{company.company_name}</strong> can now start using Faktus services!
                </p>
              </div>

              <p style='margin: 20px 0 0 0; padding-top: 15px; border-top: 1px solid #e0e0e0; color: #666; font-size: 13px;'>
                Company status: <strong style='color: #4caf50;'>Active</strong> •
                KYC status: <strong style='color: #4caf50;'>Validated</strong>
              </p>
            </div>
            "

            result_builder.success(
              message: "Company approved successfully",
              options: { html: html_content }
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

            # 6. Build HTML success modal
            notification_html = if send_notification
              "<div style='background-color: #e3f2fd; border-left: 3px solid #2196f3; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #1976d2; font-size: 14px;'>📧 Email notification will be sent to the company.</p>
              </div>"
            else
              "<div style='background-color: #f5f5f5; border-left: 3px solid #9e9e9e; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #616161; font-size: 14px;'>No notification will be sent.</p>
              </div>"
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #d32f2f; font-size: 20px;'>
                ❌ Onboarding Rejected
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                <strong>#{company.company_name}</strong> has been rejected and their account has been suspended.
              </p>

              <div style='background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 8px 0; font-weight: 600; color: #e65100; font-size: 13px; text-transform: uppercase;'>Rejection Reason</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>#{rejection_reason}</p>
              </div>

              #{notification_html}

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>Status:</strong> Suspended | <strong>KYC Status:</strong> Rejected
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Company onboarding rejected successfully",
              options: { html: html_content }
            )
          end
        )

        # Add "Escalate" smart action to Company collection
        collection.add_action(
          'Escalate',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Escalate company onboarding for additional review",
            submit_button_label: "⚠️ Escalate",
            form: [
              {
                type: FieldType::STRING,
                label: "Escalation Reason",
                id: "escalation_reason",
                description: "Explain why this company needs escalation",
                is_required: true,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the company data from Forest Admin
            company_record = context.get_record(['id', 'company_name', 'kyc_status'])

            # 2. Get the ActiveRecord model instance
            company = Company.find(company_record['id'])

            # 3. Get form values
            escalation_reason = context.get_form_value('escalation_reason')

            # 4. Update company kyc_status to escalated
            company.update!(kyc_status: 'escalated')

            # 5. Log the escalation action
            Rails.logger.info(
              "Company onboarding escalated: #{company.company_name} (ID: #{company.id}) - " \
              "Reason: #{escalation_reason}"
            )

            # 6. Build HTML success modal
            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #f57c00; font-size: 20px;'>
                ⚠️ Company Escalated for Review
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                <strong>#{company.company_name}</strong> has been escalated and will require additional review before a decision can be made.
              </p>

              <div style='background-color: #fff8e1; border-left: 4px solid #ffa726; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 8px 0; font-weight: 600; color: #e65100; font-size: 13px; text-transform: uppercase;'>Escalation Reason</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>#{escalation_reason}</p>
              </div>

              <div style='background-color: #f5f5f5; border-radius: 4px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 8px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Next Steps</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>
                  This company will require additional documentation or verification before approval.
                  Review the case details and either request more information or make a final decision.
                </p>
              </div>

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>KYC Status:</strong> Escalated
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Company escalated for review successfully",
              options: { html: html_content }
            )
          end
        )

        # Add "Request More Info" smart action to Company collection
        collection.add_action(
          'Request More Info',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Request additional information or documents from the customer",
            submit_button_label: "📨 Request More Info",
            form: [
              # Instructional text at the top
              {
                type: 'Layout',
                component: 'HtmlBlock',
                content: '<p><strong>Please select the documents that are missing</strong> (these will be requested from the customer):</p>'
              },

              # Row 1: K-bis + RIB
              {
                type: 'Layout',
                component: 'Row',
                fields: [
                  {
                    type: FieldType::BOOLEAN,
                    label: "📋 K-bis (company registration)",
                    id: "missing_kbis",
                    description: "Extract K-bis de moins de 3 mois",
                    value: false
                  },
                  {
                    type: FieldType::BOOLEAN,
                    label: "🏦 RIB (bank details)",
                    id: "missing_rib",
                    description: "Relevé d'identité bancaire",
                    value: false
                  }
                ]
              },

              # Row 2: ID Card + URSSAF Certificate
              {
                type: 'Layout',
                component: 'Row',
                fields: [
                  {
                    type: FieldType::BOOLEAN,
                    label: "🪪 ID Card of legal representative",
                    id: "missing_carte_identite",
                    description: "Carte d'identité du gérant",
                    value: false
                  },
                  {
                    type: FieldType::BOOLEAN,
                    label: "📜 URSSAF Certificate",
                    id: "missing_attestation_vigilance",
                    description: "Attestation de vigilance URSSAF à jour",
                    value: false
                  }
                ]
              },

              # Row 3: Professional Insurance + Financial Statements
              {
                type: 'Layout',
                component: 'Row',
                fields: [
                  {
                    type: FieldType::BOOLEAN,
                    label: "🛡️ Professional Liability Insurance (RCC)",
                    id: "missing_rcc",
                    description: "Assurance responsabilité civile professionnelle",
                    value: false
                  },
                  {
                    type: FieldType::BOOLEAN,
                    label: "📊 Financial Statements (Bilan)",
                    id: "missing_bilan",
                    description: "Bilan comptable de l'année N-1",
                    value: false
                  }
                ]
              },

              # Row 4: 10-Year Insurance + Qualibat Certification
              {
                type: 'Layout',
                component: 'Row',
                fields: [
                  {
                    type: FieldType::BOOLEAN,
                    label: "🏗️ 10-Year Insurance (Décennale)",
                    id: "missing_decennale",
                    description: "Assurance décennale pour le BTP",
                    value: false
                  },
                  {
                    type: FieldType::BOOLEAN,
                    label: "⭐ Qualibat Certification (optional)",
                    id: "missing_qualibat",
                    description: "Certification Qualibat",
                    value: false
                  }
                ]
              },

              # Row 5: Company Statutes (single field)
              {
                type: 'Layout',
                component: 'Row',
                fields: [
                  {
                    type: FieldType::BOOLEAN,
                    label: "📄 Company Statutes",
                    id: "missing_statuts",
                    description: "Statuts de l'entreprise",
                    value: false
                  }
                ]
              },

              # Additional notes field (full width)
              {
                type: FieldType::STRING,
                label: "Additional notes (optional)",
                id: "additional_notes",
                description: "Any additional information or specific requirements",
                is_required: false,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the company data from Forest Admin
            company_record = context.get_record(['id', 'company_name', 'kyc_status', 'contact_email'])

            # 2. Get the ActiveRecord model instance
            company = Company.find(company_record['id'])

            # 3. Collect all checked missing documents
            missing_docs = []
            missing_docs << 'K-bis (company registration)' if context.get_form_value('missing_kbis')
            missing_docs << 'RIB (bank details)' if context.get_form_value('missing_rib')
            missing_docs << 'ID Card of legal representative' if context.get_form_value('missing_carte_identite')
            missing_docs << 'URSSAF Certificate (Attestation de vigilance)' if context.get_form_value('missing_attestation_vigilance')
            missing_docs << 'Professional Liability Insurance (RCC)' if context.get_form_value('missing_rcc')
            missing_docs << 'Financial Statements (Bilan)' if context.get_form_value('missing_bilan')
            missing_docs << '10-Year Insurance (Décennale)' if context.get_form_value('missing_decennale')
            missing_docs << 'Qualibat Certification' if context.get_form_value('missing_qualibat')
            missing_docs << 'Company Statutes' if context.get_form_value('missing_statuts')

            # Get optional additional notes
            additional_notes = context.get_form_value('additional_notes')

            # 4. Validate: at least one document must be selected
            if missing_docs.empty?
              next result_builder.error(message: "❌ Please select at least one missing document before submitting.")
            end

            # 5. Update company kyc_status to waiting_on_customer
            company.update!(kyc_status: 'waiting_on_customer')

            # 6. Log the request with specific documents
            Rails.logger.info(
              "Documents requested from company: #{company.company_name} (ID: #{company.id}) - " \
              "Documents: #{missing_docs.join(', ')}#{additional_notes.present? ? " - Notes: #{additional_notes}" : ''}"
            )

            # 7. Build HTML success modal
            # Build document list as HTML
            documents_html = missing_docs.map { |doc|
              "<li style='margin: 8px 0;'>#{doc}</li>"
            }.join("\n")

            # Build notes section if present
            notes_html = if additional_notes.present?
              "<div style='margin: 15px 0; padding: 12px; background-color: #fff3e0; border-left: 3px solid #ff9800; border-radius: 4px;'>
                 <p style='margin: 0; font-weight: 600; color: #e65100;'>Additional Notes:</p>
                 <p style='margin: 8px 0 0 0; color: #333;'>#{additional_notes}</p>
               </div>"
            else
              ""
            end

            # Build complete HTML content
            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #2c3e50; font-size: 20px;'>
                📨 Missing Documents Requested
              </h3>

              <p style='margin: 15px 0; color: #333; font-size: 14px;'>
                The following documents have been requested from <strong>#{company.company_name}</strong>:
              </p>

              <ul style='margin: 15px 0; padding-left: 25px; color: #333;'>
                #{documents_html}
              </ul>

              #{notes_html}

              <div style='margin-top: 20px; padding: 15px; background-color: #e8f5e9; border-left: 4px solid #4caf50; border-radius: 4px;'>
                <p style='margin: 0; color: #2e7d32; font-size: 14px;'>
                  📧 Notification email sent to <strong>#{company.contact_email}</strong>
                </p>
              </div>

              <p style='margin: 20px 0 0 0; padding-top: 15px; border-top: 1px solid #e0e0e0; color: #666; font-size: 13px;'>
                Company status updated to: <strong style='color: #ff9800;'>Waiting on Customer</strong>
              </p>
            </div>
            "

            # Return success with HTML modal
            result_builder.success(
              message: "Documents requested successfully",
              options: { html: html_content }
            )
          end
        )
      end
    end
  end
end
