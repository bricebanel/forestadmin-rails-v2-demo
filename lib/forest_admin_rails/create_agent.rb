module ForestAdminRails
  class CreateAgent
    include ForestAdminDatasourceCustomizer::Decorators::Action::Types
    include ForestAdminDatasourceCustomizer::Decorators::Action
    include ForestAdminDatasourceCustomizer::Decorators::Computed

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

        # Add "Credit Utilization" smart field
        collection.add_field(
          'credit_utilization',
          ComputedDefinition.new(
            column_type: 'String',
            dependencies: ['id', 'credit_limit_eur'],
            values: proc { |records|
              records.map do |record|
                company = Company.find(record['id'])
                credit_limit = record['credit_limit_eur']

                if credit_limit.nil?
                  'No credit limit set'
                else
                  factoring_in_progress = company.total_factoring_in_progress
                  percentage = credit_limit > 0 ? ((factoring_in_progress / credit_limit) * 100).round(1) : 0

                  # Format amounts with thousands separator (space for French format)
                  formatted_factoring = factoring_in_progress.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
                  formatted_limit = credit_limit.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse

                  "€#{formatted_factoring} / €#{formatted_limit} (#{percentage}%)"
                end
              end
            }
          )
        )

        # Add "Missing KYC Documents" smart field
        collection.add_field(
          'missing_kyc_documents',
          ComputedDefinition.new(
            column_type: 'String',
            dependencies: ['id'],
            values: proc { |records|
              # Document type labels mapping
              doc_labels_map = {
                'kbis' => 'K-bis',
                'attestation_vigilance' => 'Attestation Vigilance',
                'rcc' => 'RCC',
                'attestation_assurance' => 'Attestation Assurance',
                'rib' => 'RIB',
                'carte_identite' => 'Carte Identité',
                'statuts' => 'Statuts',
                'liasse_fiscale' => 'Liasse Fiscale',
                'bilan' => 'Bilan',
                'decennale' => 'Décennale',
                'qualibat' => 'Qualibat',
                'autre' => 'Autre'
              }

              records.map do |record|
                company = Company.find(record['id'])

                # Check if company has any documents
                if company.kyc_documents.empty?
                  'No documents submitted'
                else
                  # Get documents that are missing or rejected
                  problematic_docs = company.kyc_documents.where(status: ['missing', 'rejected'])

                  if problematic_docs.empty?
                    '✓ All documents complete'
                  else
                    # Convert document types to readable labels
                    doc_names = problematic_docs.map do |doc|
                      doc_labels_map[doc.document_type] || doc.document_type.capitalize
                    end.uniq.sort

                    doc_names.join(', ')
                  end
                end
              end
            }
          )
        )

        # Add "Health Score" smart field
        collection.add_field(
          'health_score',
          ComputedDefinition.new(
            column_type: 'String',
            dependencies: ['id', 'kyc_status', 'status', 'credit_limit_eur'],
            values: proc { |records|
              records.map do |record|
                company = Company.find(record['id'])
                kyc_status = record['kyc_status']
                status = record['status']
                credit_limit = record['credit_limit_eur']

                # Calculate credit utilization percentage if applicable
                credit_utilization = if credit_limit && credit_limit > 0
                                       factoring_in_progress = company.total_factoring_in_progress
                                       ((factoring_in_progress / credit_limit) * 100).round(1)
                                     else
                                       0
                                     end

                # Determine health score based on multiple factors
                if status == 'suspended' || status == 'closed' || kyc_status == 'rejected'
                  '🔴 Poor'
                elsif kyc_status == 'escalated' || kyc_status == 'waiting_on_customer' ||
                      credit_utilization > 80 ||
                      (credit_limit.nil? && kyc_status != 'validated')
                  '🟠 Fair'
                elsif kyc_status == 'validated' && status == 'active' && credit_utilization < 50
                  '🟢 Excellent'
                else
                  '🟡 Good'
                end
              end
            }
          )
        )
      end

      # Add "Update Document Status" smart action to KycDocument collection
      @create_agent.customize_collection('KycDocument') do |collection|
        collection.add_action(
          'Update Document Status',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Update the status of a KYC document",
            submit_button_label: "📝 Update Status",
            form: [
              {
                type: FieldType::ENUM,
                label: "New Status",
                id: "new_status",
                description: "Select the new status for this document",
                is_required: true,
                enum_values: ['pending_review', 'approved', 'rejected', 'missing', 'expired']
              },
              {
                type: FieldType::STRING,
                label: "Notes",
                id: "notes",
                description: "Add any notes about this document review",
                is_required: false,
                widget: 'TextArea'
              },
              {
                type: FieldType::STRING,
                label: "Rejection Reason",
                id: "rejection_reason",
                description: "Required if status is Rejected - explain why the document was rejected",
                is_required: false,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the KYC document data from Forest Admin
            document_record = context.get_record(['id', 'document_type', 'company_id', 'status'])

            # 2. Get the ActiveRecord model instance
            document = KycDocument.find(document_record['id'])

            # 3. Get form values
            new_status = context.get_form_value('new_status')
            notes = context.get_form_value('notes')
            rejection_reason = context.get_form_value('rejection_reason')

            # 4. Validation: rejection reason required if status is rejected
            if new_status == 'rejected' && rejection_reason.blank?
              next result_builder.error(message: "Rejection reason is required when rejecting a document")
            end

            # 5. Update document
            document.update!(
              status: new_status,
              notes: notes.presence,
              rejection_reason: (new_status == 'rejected' ? rejection_reason : nil),
              reviewed_at: Time.current,
              reviewed_by: 'Admin'
            )

            # 6. Log the action
            Rails.logger.info(
              "KYC Document status updated: Document ID #{document.id} (#{document.document_type}) - " \
              "Company: #{document.company.company_name} - New Status: #{new_status}"
            )

            # 7. Build HTML success modal
            company = document.company

            # Document type labels mapping
            doc_labels_map = {
              'kbis' => 'K-bis',
              'attestation_vigilance' => 'Attestation Vigilance',
              'rcc' => 'RCC',
              'attestation_assurance' => 'Attestation Assurance',
              'rib' => 'RIB',
              'carte_identite' => 'Carte Identité',
              'statuts' => 'Statuts',
              'liasse_fiscale' => 'Liasse Fiscale',
              'bilan' => 'Bilan',
              'decennale' => 'Décennale',
              'qualibat' => 'Qualibat',
              'autre' => 'Autre'
            }
            doc_label = doc_labels_map[document.document_type] || document.document_type.capitalize

            # Status colors
            status_colors = {
              'approved' => '#4caf50',
              'rejected' => '#f44336',
              'pending_review' => '#ff9800',
              'missing' => '#9e9e9e',
              'expired' => '#757575'
            }
            status_color = status_colors[new_status] || '#2196f3'

            # Status emojis
            status_emojis = {
              'approved' => '✅',
              'rejected' => '❌',
              'pending_review' => '⏳',
              'missing' => '📋',
              'expired' => '⌛'
            }
            status_emoji = status_emojis[new_status] || '📄'

            # Build notes section if provided
            notes_html = if notes.present?
              "<div style='background-color: #e3f2fd; border-left: 3px solid #2196f3; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #1976d2; font-size: 13px;'>NOTES</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>#{notes}</p>
              </div>"
            else
              ''
            end

            # Build rejection reason section if provided
            rejection_html = if rejection_reason.present?
              "<div style='background-color: #ffebee; border-left: 3px solid #f44336; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #d32f2f; font-size: 13px;'>REJECTION REASON</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>#{rejection_reason}</p>
              </div>"
            else
              ''
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #{status_color}; font-size: 20px;'>
                #{status_emoji} Document Status Updated
              </h3>

              <div style='background-color: #f5f5f5; border-radius: 4px; padding: 15px; margin-bottom: 15px;'>
                <p style='margin: 0 0 8px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Document Details</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Type:</strong> #{doc_label}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Company:</strong> #{company.company_name}</p>
                <p style='margin: 0; color: #555; font-size: 14px;'><strong>New Status:</strong> <span style='color: #{status_color}; font-weight: 600;'>#{new_status.humanize}</span></p>
              </div>

              #{notes_html}
              #{rejection_html}

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  Reviewed by Admin on #{Time.current.strftime('%B %d, %Y at %H:%M')}
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Document status updated successfully",
              options: { html: html_content }
            )
          end
        )
      end

      # Add "Approve factoring request" smart action to FactoringOperation collection
      @create_agent.customize_collection('FactoringOperation') do |collection|
        collection.add_action(
          'Approve factoring request',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Approve a factoring request and mark it ready for funding",
            submit_button_label: "✅ Approve & Continue",
            form: [
              {
                type: FieldType::NUMBER,
                label: "Risk Score (0-100)",
                id: "risk_score",
                description: "Risk assessment for this factoring operation",
                is_required: true,
                value: 50
              },
              {
                type: FieldType::NUMBER,
                label: "Advance Rate (%)",
                id: "advance_rate",
                description: "Percentage of invoice to advance (leave blank to keep current rate)",
                is_required: false
              },
              {
                type: FieldType::NUMBER,
                label: "Fee Rate (%)",
                id: "fee_rate",
                description: "Factoring fee percentage (leave blank to keep current rate)",
                is_required: false
              },
              {
                type: FieldType::STRING,
                label: "Approver Name",
                id: "approver_name",
                description: "Your name as the approver",
                is_required: true
              },
              {
                type: FieldType::STRING,
                label: "Approval Notes",
                id: "approval_notes",
                description: "Justification for approving this factoring request",
                is_required: true,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the factoring operation data from Forest Admin
            operation_record = context.get_record([
              'id', 'status', 'company_id', 'invoice_id', 'invoice_amount',
              'advance_rate', 'fee_rate', 'advance_amount', 'fee_amount', 'net_amount'
            ])

            # 2. Get the ActiveRecord model instance
            operation = FactoringOperation.find(operation_record['id'])
            company = operation.company
            invoice = operation.invoice

            # 3. Validate: Only pending or under_review status can be approved
            unless ['pending', 'under_review'].include?(operation.status)
              next result_builder.error(
                message: "❌ Cannot approve: This factoring operation has status '#{operation.status}'. " \
                         "Only 'pending' or 'under_review' operations can be approved."
              )
            end

            # 4. Validate: Company must have sufficient available credit
            available_credit = company.available_credit
            if available_credit < operation.advance_amount
              formatted_available = available_credit.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              formatted_needed = operation.advance_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              next result_builder.error(
                message: "❌ Insufficient credit: #{company.company_name} has only €#{formatted_available} available, " \
                         "but this operation requires €#{formatted_needed}."
              )
            end

            # 5. Get form values
            risk_score = context.get_form_value('risk_score')
            new_advance_rate = context.get_form_value('advance_rate')
            new_fee_rate = context.get_form_value('fee_rate')
            approver_name = context.get_form_value('approver_name')
            approval_notes = context.get_form_value('approval_notes')

            # 6. Validate risk score
            if risk_score < 0 || risk_score > 100
              next result_builder.error(message: "❌ Risk score must be between 0 and 100")
            end

            # 7. Update operation with new rates if provided, which will trigger recalculation
            update_params = { risk_score: risk_score }
            update_params[:advance_rate] = new_advance_rate if new_advance_rate.present?
            update_params[:fee_rate] = new_fee_rate if new_fee_rate.present?

            operation.update!(update_params)

            # 8. Approve the operation (uses the model's approve! method)
            operation.approve!(approver_name)

            # 9. Reload to get recalculated amounts
            operation.reload

            # 10. Log the approval action
            Rails.logger.info(
              "Factoring operation approved: Operation ID #{operation.id} - " \
              "Company: #{company.company_name} - Invoice: #{invoice.invoice_number} - " \
              "Risk Score: #{risk_score} - Approver: #{approver_name} - Notes: #{approval_notes}"
            )

            # 11. Build HTML success modal
            # Format amounts with thousands separator
            formatted_invoice_amount = operation.invoice_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_advance_amount = operation.advance_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_fee_amount = operation.fee_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_net_amount = operation.net_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse

            # Risk score badge color
            risk_color = if risk_score >= 70
              '#f44336'  # Red for high risk
            elsif risk_score >= 50
              '#ff9800'  # Orange for medium risk
            else
              '#4caf50'  # Green for low risk
            end

            risk_label = if risk_score >= 70
              'High Risk'
            elsif risk_score >= 50
              'Medium Risk'
            else
              'Low Risk'
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #4caf50; font-size: 20px;'>
                ✅ Factoring Request Approved
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                The factoring operation for <strong>#{company.company_name}</strong> has been approved and is ready for funding.
              </p>

              <div style='background-color: #f5f5f5; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 10px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Operation Details</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Company:</strong> #{company.company_name}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Invoice:</strong> #{invoice.invoice_number}</p>
                <p style='margin: 0; color: #555; font-size: 14px;'><strong>Invoice Date:</strong> #{invoice.invoice_date.strftime('%B %d, %Y')}</p>
              </div>

              <div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 12px 0; font-size: 13px; color: #2e7d32; font-weight: 600; text-transform: uppercase;'>Financial Breakdown</p>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Invoice Amount:</span>
                  <span style='color: #2c3e50; font-size: 14px; font-weight: 600;'>€#{formatted_invoice_amount}</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Advance Rate:</span>
                  <span style='color: #2c3e50; font-size: 14px; font-weight: 600;'>#{operation.advance_rate}%</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Advance Amount:</span>
                  <span style='color: #2c3e50; font-size: 14px; font-weight: 600;'>€#{formatted_advance_amount}</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Fee Rate:</span>
                  <span style='color: #2c3e50; font-size: 14px; font-weight: 600;'>#{operation.fee_rate}%</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 12px;'>
                  <span style='color: #555; font-size: 14px;'>Fee Amount:</span>
                  <span style='color: #d32f2f; font-size: 14px; font-weight: 600;'>-€#{formatted_fee_amount}</span>
                </div>
                <div style='border-top: 2px solid #4caf50; padding-top: 12px; display: flex; justify-content: space-between;'>
                  <span style='color: #2e7d32; font-size: 16px; font-weight: 600;'>Net Amount to Company:</span>
                  <span style='color: #2e7d32; font-size: 18px; font-weight: 700;'>€#{formatted_net_amount}</span>
                </div>
              </div>

              <div style='background-color: #fff; border: 1px solid #e0e0e0; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <div style='display: flex; justify-content: space-between; align-items: center;'>
                  <div>
                    <p style='margin: 0 0 5px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Risk Assessment</p>
                    <p style='margin: 0; font-size: 24px; font-weight: 700; color: #{risk_color};'>#{risk_score}/100</p>
                  </div>
                  <div style='background-color: #{risk_color}; color: white; padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 600;'>
                    #{risk_label}
                  </div>
                </div>
              </div>

              <div style='background-color: #e3f2fd; border-left: 3px solid #2196f3; padding: 12px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 8px 0; font-weight: 600; color: #1565c0; font-size: 13px; text-transform: uppercase;'>Approval Notes</p>
                <p style='margin: 0; color: #333; font-size: 14px; line-height: 1.5;'>#{approval_notes}</p>
              </div>

              <div style='background-color: #fff8e1; border-left: 4px solid #ffa726; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  ⚠️ <strong>Next Step:</strong> Use the \"Fund Operation\" action to release the advance payment to the company's account.
                </p>
              </div>

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>Approved by:</strong> #{approver_name} on #{operation.approved_at.strftime('%B %d, %Y at %H:%M')}
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Factoring request approved successfully",
              options: { html: html_content }
            )
          end
        )

        # Add "Reject factoring request" smart action to FactoringOperation collection
        collection.add_action(
          'Reject factoring request',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Reject a factoring request with a reason",
            submit_button_label: "❌ Reject Request",
            form: [
              {
                type: FieldType::ENUM,
                label: "Rejection Reason",
                id: "rejection_reason",
                description: "Select the primary reason for rejection",
                is_required: true,
                enum_values: [
                  'insufficient_credit',
                  'high_risk',
                  'missing_documents',
                  'fraudulent_invoice',
                  'invoice_not_verified',
                  'other'
                ]
              },
              {
                type: FieldType::STRING,
                label: "Detailed Notes",
                id: "detailed_notes",
                description: "Provide detailed explanation for the rejection",
                is_required: true,
                widget: 'TextArea'
              },
              {
                type: FieldType::BOOLEAN,
                label: "Notify Company",
                id: "notify_company",
                description: "Send rejection notification email to the company",
                value: true
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the factoring operation data
            operation_record = context.get_record(['id', 'status', 'company_id', 'invoice_id'])

            # 2. Get the ActiveRecord model instance
            operation = FactoringOperation.find(operation_record['id'])
            company = operation.company
            invoice = operation.invoice

            # 3. Validate: Only pending or under_review status can be rejected
            unless ['pending', 'under_review'].include?(operation.status)
              next result_builder.error(
                message: "❌ Cannot reject: This factoring operation has status '#{operation.status}'. " \
                         "Only 'pending' or 'under_review' operations can be rejected."
              )
            end

            # 4. Get form values
            rejection_reason = context.get_form_value('rejection_reason')
            detailed_notes = context.get_form_value('detailed_notes')
            notify_company = context.get_form_value('notify_company')

            # 5. Reject the operation using model method
            operation.reject!(detailed_notes)

            # 6. Store the rejection reason category (could add a field to model, for now just in notes)
            operation.update!(rejection_reason: "#{rejection_reason}: #{detailed_notes}")

            # 7. Log the rejection
            Rails.logger.info(
              "Factoring operation rejected: Operation ID #{operation.id} - " \
              "Company: #{company.company_name} - Invoice: #{invoice.invoice_number} - " \
              "Reason: #{rejection_reason} - Notes: #{detailed_notes} - Notify: #{notify_company}"
            )

            # 8. Build HTML success modal
            # Rejection reason labels
            reason_labels = {
              'insufficient_credit' => '💳 Insufficient Credit',
              'high_risk' => '⚠️ High Risk Assessment',
              'missing_documents' => '📋 Missing Documents',
              'fraudulent_invoice' => '🚨 Fraudulent Invoice',
              'invoice_not_verified' => '❓ Invoice Not Verified',
              'other' => '📝 Other Reason'
            }
            reason_label = reason_labels[rejection_reason] || rejection_reason

            # Format invoice amount
            formatted_invoice_amount = invoice.amount_ttc.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse

            # Notification section
            notification_html = if notify_company
              "<div style='background-color: #e3f2fd; border-left: 3px solid #2196f3; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #1976d2; font-size: 14px;'>📧 Notification email will be sent to <strong>#{company.contact_email}</strong></p>
              </div>"
            else
              "<div style='background-color: #f5f5f5; border-left: 3px solid #9e9e9e; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #616161; font-size: 14px;'>No notification will be sent to the company.</p>
              </div>"
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #d32f2f; font-size: 20px;'>
                ❌ Factoring Request Rejected
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                The factoring request from <strong>#{company.company_name}</strong> has been rejected.
              </p>

              <div style='background-color: #f5f5f5; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 10px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Request Details</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Company:</strong> #{company.company_name}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Invoice:</strong> #{invoice.invoice_number}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Invoice Amount:</strong> €#{formatted_invoice_amount}</p>
                <p style='margin: 0; color: #555; font-size: 14px;'><strong>Invoice Date:</strong> #{invoice.invoice_date.strftime('%B %d, %Y')}</p>
              </div>

              <div style='background-color: #ffebee; border-left: 4px solid #f44336; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 10px 0; font-weight: 600; color: #c62828; font-size: 13px; text-transform: uppercase;'>Rejection Reason</p>
                <p style='margin: 0 0 10px 0; color: #d32f2f; font-size: 16px; font-weight: 600;'>#{reason_label}</p>
                <p style='margin: 0; color: #555; font-size: 14px; line-height: 1.5;'>#{detailed_notes}</p>
              </div>

              #{notification_html}

              <div style='background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 15px; border-radius: 4px; margin-top: 20px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  💡 <strong>Next Steps:</strong> The company may resubmit with corrections, or you can archive this request.
                </p>
              </div>

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>Status:</strong> Rejected on #{Time.current.strftime('%B %d, %Y at %H:%M')}
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Factoring request rejected successfully",
              options: { html: html_content }
            )
          end
        )

        # Add "Fund Operation" smart action to FactoringOperation collection
        collection.add_action(
          'Fund Operation',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Release the advance payment to the company's account",
            submit_button_label: "💰 Fund Now",
            form: [
              {
                type: FieldType::BOOLEAN,
                label: "⚠️ I confirm the advance payment will be transferred",
                id: "confirm_funding",
                description: "This action will create financial transactions and cannot be easily reversed",
                is_required: true,
                value: false
              },
              {
                type: FieldType::STRING,
                label: "Payment Reference (optional)",
                id: "payment_reference",
                description: "Bank transfer reference or transaction ID",
                is_required: false
              },
              {
                type: FieldType::STRING,
                label: "Notes (optional)",
                id: "funding_notes",
                description: "Any additional notes about this funding",
                is_required: false,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the factoring operation data
            operation_record = context.get_record([
              'id', 'status', 'company_id', 'invoice_id',
              'advance_amount', 'fee_amount', 'net_amount', 'invoice_amount'
            ])

            # 2. Get the ActiveRecord model instances
            operation = FactoringOperation.find(operation_record['id'])
            company = operation.company
            invoice = operation.invoice

            # 3. Validate: Only approved status can be funded
            unless operation.status == 'approved'
              next result_builder.error(
                message: "❌ Cannot fund: This factoring operation has status '#{operation.status}'. " \
                         "Only 'approved' operations can be funded. Please approve the operation first."
              )
            end

            # 4. Get form values
            confirm_funding = context.get_form_value('confirm_funding')
            payment_reference = context.get_form_value('payment_reference')
            funding_notes = context.get_form_value('funding_notes')

            # 5. Validate: Confirmation must be checked
            unless confirm_funding
              next result_builder.error(
                message: "❌ Please confirm the funding by checking the confirmation box."
              )
            end

            # 6. Get current company account balance
            current_balance = company.account_balance

            # 7. Create account transactions (atomic operation with ActiveRecord transaction)
            advance_transaction = nil
            fee_transaction = nil

            begin
              ActiveRecord::Base.transaction do
                # First transaction: Credit company with advance amount
                advance_transaction = AccountTransaction.create_factoring_advance!(
                  company: company,
                  factoring_operation: operation,
                  amount: operation.advance_amount,
                  balance_before: current_balance
                )

                # Second transaction: Debit company with fee amount
                # Balance after advance is now current_balance + advance_amount
                fee_transaction = AccountTransaction.create_factoring_fee!(
                  company: company,
                  factoring_operation: operation,
                  amount: operation.fee_amount,
                  balance_before: current_balance + operation.advance_amount
                )

                # Update operation status to funded
                operation.fund!

                # Store payment reference if provided
                if payment_reference.present?
                  operation.update!(rejection_reason: nil) # Clear any old data
                  # Note: Could add a payment_reference field to the model in the future
                end
              end
            rescue => e
              Rails.logger.error("Failed to fund operation #{operation.id}: #{e.message}")
              next result_builder.error(
                message: "❌ Funding failed: #{e.message}. No transactions were created."
              )
            end

            # 8. Calculate new balance (should match fee_transaction.balance_after)
            new_balance = current_balance + operation.net_amount

            # 9. Log the funding with transaction details
            Rails.logger.info(
              "Factoring operation funded: Operation ID #{operation.id} - " \
              "Company: #{company.company_name} - Invoice: #{invoice.invoice_number} - " \
              "Net Amount: €#{operation.net_amount} - " \
              "Transactions: Advance #{advance_transaction.id}, Fee #{fee_transaction.id} - " \
              "Payment Ref: #{payment_reference} - Notes: #{funding_notes}"
            )

            # 10. Build HTML success modal
            # Format amounts
            formatted_invoice = operation.invoice_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_advance = operation.advance_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_fee = operation.fee_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_net = operation.net_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_old_balance = current_balance.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_new_balance = new_balance.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse

            # Payment reference section
            payment_ref_html = if payment_reference.present?
              "<div style='background-color: #e3f2fd; border-left: 3px solid #2196f3; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #1565c0; font-size: 13px;'>PAYMENT REFERENCE</p>
                <p style='margin: 0; color: #333; font-size: 14px;'>#{payment_reference}</p>
              </div>"
            else
              ""
            end

            # Notes section
            notes_html = if funding_notes.present?
              "<div style='background-color: #f5f5f5; border-left: 3px solid #757575; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #616161; font-size: 13px;'>NOTES</p>
                <p style='margin: 0; color: #333; font-size: 14px; line-height: 1.5;'>#{funding_notes}</p>
              </div>"
            else
              ""
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #4caf50; font-size: 20px;'>
                💰 Factoring Operation Funded Successfully
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                The advance payment has been transferred to <strong>#{company.company_name}</strong>'s account.
              </p>

              <div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 15px; border-radius: 4px; margin-bottom: 20px;'>
                <p style='margin: 0 0 12px 0; font-size: 13px; color: #2e7d32; font-weight: 600; text-transform: uppercase;'>Transaction Summary</p>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Invoice Amount:</span>
                  <span style='color: #2c3e50; font-size: 14px; font-weight: 600;'>€#{formatted_invoice}</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 8px;'>
                  <span style='color: #555; font-size: 14px;'>Advance (#{operation.advance_rate}%):</span>
                  <span style='color: #4caf50; font-size: 14px; font-weight: 600;'>+€#{formatted_advance}</span>
                </div>
                <div style='display: flex; justify-content: space-between; margin-bottom: 12px;'>
                  <span style='color: #555; font-size: 14px;'>Factoring Fee (#{operation.fee_rate}%):</span>
                  <span style='color: #d32f2f; font-size: 14px; font-weight: 600;'>-€#{formatted_fee}</span>
                </div>
                <div style='border-top: 2px solid #4caf50; padding-top: 12px; display: flex; justify-content: space-between;'>
                  <span style='color: #2e7d32; font-size: 16px; font-weight: 600;'>Net Transfer:</span>
                  <span style='color: #2e7d32; font-size: 18px; font-weight: 700;'>€#{formatted_net}</span>
                </div>
              </div>

              <div style='background-color: #fff; border: 1px solid #e0e0e0; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 12px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Company Account Balance</p>
                <div style='display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;'>
                  <span style='color: #555; font-size: 14px;'>Previous Balance:</span>
                  <span style='color: #757575; font-size: 16px;'>€#{formatted_old_balance}</span>
                </div>
                <div style='display: flex; justify-content: space-between; align-items: center;'>
                  <span style='color: #2e7d32; font-size: 14px; font-weight: 600;'>New Balance:</span>
                  <span style='color: #2e7d32; font-size: 20px; font-weight: 700;'>€#{formatted_new_balance}</span>
                </div>
              </div>

              <div style='background-color: #f5f5f5; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 10px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Transaction IDs</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Advance Transaction:</strong> ##{advance_transaction.id}</p>
                <p style='margin: 0; color: #555; font-size: 14px;'><strong>Fee Transaction:</strong> ##{fee_transaction.id}</p>
              </div>

              #{payment_ref_html}
              #{notes_html}

              <div style='background-color: #fff8e1; border-left: 4px solid #ffa726; padding: 15px; border-radius: 4px; margin-top: 20px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  ⏳ <strong>Next Step:</strong> Wait for the end customer to pay Invoice ##{invoice.invoice_number}.
                  Once payment is received, use the \"Mark Invoice as Paid\" action to complete this factoring operation.
                </p>
              </div>

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>Funded on:</strong> #{operation.funded_at.strftime('%B %d, %Y at %H:%M')} |
                  <strong>Invoice Due:</strong> #{invoice.due_date.strftime('%B %d, %Y')}
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Operation funded successfully - €#{formatted_net} transferred",
              options: { html: html_content }
            )
          end
        )
      end

      # Add "Mark Invoice as Paid" smart action to Invoice collection
      @create_agent.customize_collection('Invoice') do |collection|
        collection.add_action(
          'Mark Invoice as Paid',
          BaseAction.new(
            scope: ActionScope::SINGLE,
            description: "Record that the end customer has paid this invoice",
            submit_button_label: "✅ Mark as Paid",
            form: [
              {
                type: FieldType::DATE,
                label: "Payment Date",
                id: "payment_date",
                description: "Date when the payment was received",
                is_required: true
              },
              {
                type: FieldType::NUMBER,
                label: "Payment Amount Received (€)",
                id: "payment_amount",
                description: "Amount received from the customer",
                is_required: true
              },
              {
                type: FieldType::ENUM,
                label: "Payment Method",
                id: "payment_method",
                description: "How the customer paid",
                is_required: true,
                enum_values: ['bank_transfer', 'check', 'cash', 'wire_transfer', 'other']
              },
              {
                type: FieldType::STRING,
                label: "Payment Reference (optional)",
                id: "payment_reference",
                description: "Transaction or check reference number",
                is_required: false
              },
              {
                type: FieldType::STRING,
                label: "Notes (optional)",
                id: "payment_notes",
                description: "Any additional details about the payment",
                is_required: false,
                widget: 'TextArea'
              }
            ]
          ) do |context, result_builder|
            # 1. Fetch the invoice data
            invoice_record = context.get_record([
              'id', 'payment_status', 'invoice_number', 'amount_ttc',
              'company_id', 'due_date', 'invoice_date'
            ])

            # 2. Get the ActiveRecord model instances
            invoice = Invoice.find(invoice_record['id'])
            company = invoice.company
            factoring_operation = invoice.factoring_operation

            # 3. Validate: Invoice must be pending or overdue
            unless ['pending', 'overdue'].include?(invoice.payment_status)
              next result_builder.error(
                message: "❌ Cannot mark as paid: This invoice has payment status '#{invoice.payment_status}'. " \
                         "Only 'pending' or 'overdue' invoices can be marked as paid."
              )
            end

            # 4. Get form values
            payment_date = context.get_form_value('payment_date')
            payment_amount = context.get_form_value('payment_amount')
            payment_method = context.get_form_value('payment_method')
            payment_reference = context.get_form_value('payment_reference')
            payment_notes = context.get_form_value('payment_notes')

            # 5. Validate payment amount
            if payment_amount <= 0
              next result_builder.error(message: "❌ Payment amount must be greater than 0")
            end

            # 6. Check if payment is partial
            is_partial_payment = (payment_amount - invoice.amount_ttc).abs > 0.01
            payment_difference = payment_amount - invoice.amount_ttc

            # 7. Parse payment date (Forest Admin sends date as string)
            payment_date_parsed = if payment_date.is_a?(String)
              Date.parse(payment_date)
            else
              payment_date
            end

            # 8. Update invoice
            if is_partial_payment && payment_difference < 0
              # Partial payment (less than full amount)
              invoice.update!(
                payment_status: 'partially_paid',
                paid_at: payment_date_parsed
              )
            else
              # Full payment (or overpayment)
              invoice.update!(
                payment_status: 'paid',
                paid_at: payment_date_parsed
              )
            end

            # 9. Calculate payment delay (days late or early)
            payment_delay = (payment_date_parsed - invoice.due_date).to_i
            invoice.update!(payment_delay_days: payment_delay)

            # 10. If invoice has a factoring operation and it's funded, complete it
            factoring_completed = false
            if factoring_operation && factoring_operation.status == 'funded'
              factoring_operation.complete_final_payment!
              factoring_completed = true
            end

            # 11. Log the payment
            Rails.logger.info(
              "Invoice marked as paid: Invoice ##{invoice.invoice_number} - " \
              "Company: #{company.company_name} - " \
              "Amount: €#{payment_amount} - Method: #{payment_method} - " \
              "Payment Delay: #{payment_delay} days - " \
              "Factoring Completed: #{factoring_completed} - " \
              "Reference: #{payment_reference} - Notes: #{payment_notes}"
            )

            # 12. Build HTML success modal
            # Format amounts
            formatted_invoice_amount = invoice.amount_ttc.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
            formatted_payment_amount = payment_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse

            # Payment method labels
            payment_method_labels = {
              'bank_transfer' => '🏦 Bank Transfer',
              'check' => '📝 Check',
              'cash' => '💵 Cash',
              'wire_transfer' => '💸 Wire Transfer',
              'other' => '📋 Other'
            }
            payment_method_label = payment_method_labels[payment_method] || payment_method

            # Payment delay indicator
            delay_html = if payment_delay < 0
              days_early = payment_delay.abs
              "<div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 12px; border-radius: 4px;'>
                <p style='margin: 0; color: #2e7d32; font-size: 14px;'>
                  ✅ <strong>Paid Early:</strong> #{days_early} day#{days_early > 1 ? 's' : ''} before due date
                </p>
              </div>"
            elsif payment_delay == 0
              "<div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 12px; border-radius: 4px;'>
                <p style='margin: 0; color: #2e7d32; font-size: 14px;'>
                  ✅ <strong>Paid On Time:</strong> Received on due date
                </p>
              </div>"
            else
              "<div style='background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 12px; border-radius: 4px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  ⚠️ <strong>Paid Late:</strong> #{payment_delay} day#{payment_delay > 1 ? 's' : ''} after due date
                </p>
              </div>"
            end

            # Partial payment warning
            partial_payment_html = if is_partial_payment && payment_difference < 0
              remaining = (invoice.amount_ttc - payment_amount).abs
              formatted_remaining = remaining.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              "<div style='background-color: #fff8e1; border-left: 4px solid #ffa726; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  ⚠️ <strong>Partial Payment:</strong> €#{formatted_remaining} still outstanding
                </p>
              </div>"
            elsif is_partial_payment && payment_difference > 0
              overpayment = payment_difference.abs
              formatted_overpayment = overpayment.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              "<div style='background-color: #e3f2fd; border-left: 4px solid #2196f3; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #1976d2; font-size: 14px;'>
                  ℹ️ <strong>Overpayment:</strong> €#{formatted_overpayment} more than invoice amount
                </p>
              </div>"
            else
              ""
            end

            # Factoring completion section
            factoring_html = if factoring_completed
              formatted_advance = factoring_operation.advance_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              formatted_fee = factoring_operation.fee_amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
              days_funded = (Date.today - factoring_operation.funded_at.to_date).to_i

              "<div style='background-color: #e8f5e9; border-left: 4px solid #4caf50; padding: 15px; border-radius: 4px; margin-top: 20px;'>
                <p style='margin: 0 0 10px 0; font-weight: 600; color: #2e7d32; font-size: 15px;'>
                  💰 Factoring Operation Completed
                </p>
                <p style='margin: 0 0 8px 0; color: #555; font-size: 14px;'>
                  The factoring operation has been automatically marked as completed.
                </p>
                <div style='background-color: rgba(255,255,255,0.7); padding: 10px; border-radius: 4px; margin-top: 10px;'>
                  <p style='margin: 0 0 5px 0; color: #555; font-size: 13px;'><strong>Advance Paid:</strong> €#{formatted_advance}</p>
                  <p style='margin: 0 0 5px 0; color: #555; font-size: 13px;'><strong>Fee Earned:</strong> €#{formatted_fee}</p>
                  <p style='margin: 0; color: #555; font-size: 13px;'><strong>Duration:</strong> #{days_funded} day#{days_funded > 1 ? 's' : ''} funded</p>
                </div>
              </div>"
            elsif factoring_operation
              "<div style='background-color: #fff3e0; border-left: 4px solid #ff9800; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0; color: #e65100; font-size: 14px;'>
                  ℹ️ This invoice has a factoring operation with status: <strong>#{factoring_operation.status}</strong>
                </p>
              </div>"
            else
              ""
            end

            # Payment reference section
            payment_ref_html = if payment_reference.present?
              "<div style='background-color: #f5f5f5; border-left: 3px solid #757575; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #616161; font-size: 13px;'>PAYMENT REFERENCE</p>
                <p style='margin: 0; color: #333; font-size: 14px;'>#{payment_reference}</p>
              </div>"
            else
              ""
            end

            # Notes section
            notes_html = if payment_notes.present?
              "<div style='background-color: #f5f5f5; border-left: 3px solid #757575; padding: 12px; border-radius: 4px; margin-top: 15px;'>
                <p style='margin: 0 0 5px 0; font-weight: 600; color: #616161; font-size: 13px;'>NOTES</p>
                <p style='margin: 0; color: #333; font-size: 14px; line-height: 1.5;'>#{payment_notes}</p>
              </div>"
            else
              ""
            end

            html_content = "
            <div style='padding: 20px; font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, \"Helvetica Neue\", Arial, sans-serif;'>
              <h3 style='margin-top: 0; margin-bottom: 15px; color: #4caf50; font-size: 20px;'>
                ✅ Invoice Marked as Paid
              </h3>

              <p style='margin: 0 0 20px 0; color: #555; font-size: 14px;'>
                Invoice <strong>##{invoice.invoice_number}</strong> from <strong>#{company.company_name}</strong> has been marked as paid.
              </p>

              <div style='background-color: #f5f5f5; border-radius: 6px; padding: 15px; margin-bottom: 20px;'>
                <p style='margin: 0 0 10px 0; font-size: 12px; color: #757575; text-transform: uppercase; font-weight: 600;'>Payment Details</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Invoice Amount:</strong> €#{formatted_invoice_amount}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Payment Received:</strong> €#{formatted_payment_amount}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Payment Date:</strong> #{payment_date_parsed.strftime('%B %d, %Y')}</p>
                <p style='margin: 0 0 5px 0; color: #555; font-size: 14px;'><strong>Due Date:</strong> #{invoice.due_date.strftime('%B %d, %Y')}</p>
                <p style='margin: 0; color: #555; font-size: 14px;'><strong>Method:</strong> #{payment_method_label}</p>
              </div>

              #{delay_html}
              #{partial_payment_html}
              #{factoring_html}
              #{payment_ref_html}
              #{notes_html}

              <div style='margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0;'>
                <p style='margin: 0; color: #757575; font-size: 12px;'>
                  <strong>Invoice Status:</strong> #{invoice.payment_status.humanize} |
                  <strong>Payment Delay:</strong> #{payment_delay} day#{payment_delay.abs > 1 ? 's' : ''}
                </p>
              </div>
            </div>
            "

            result_builder.success(
              message: "Invoice marked as paid successfully",
              options: { html: html_content }
            )
          end
        )
      end
    end
  end
end
