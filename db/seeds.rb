puts "🧹 Nettoyage de la base de données..."
AccountTransaction.destroy_all
RetentionGuarantee.destroy_all
FactoringOperation.destroy_all
Invoice.destroy_all
ProjectParticipant.destroy_all
Project.destroy_all
Company.destroy_all

puts "\n🏢 Création des entreprises BTP..."

# Entreprises principales (clients Faktus)
companies_data = [
  {
    company_name: "Bâtiments Modernes SAS",
    siret: "85234567890123",
    legal_form: "SAS",
    contact_name: "Jean Dupont",
    contact_email: "j.dupont@batiments-modernes.fr",
    contact_phone: "01 45 67 89 01",
    city: "Lyon",
    postal_code: "69002",
    specialization: "Gros œuvre",
    status: "active",
    kyc_status: "validated",
    company_size: "pme",
    credit_limit_eur: 500_000,
    annual_revenue: 2_500_000,
    employee_count: 35,
    registration_date: 5.years.ago,
    iban: "FR7630006000011234567890189",
    logo_url: "https://via.placeholder.com/150/0066cc/ffffff?text=BM"
  },
  {
    company_name: "Électricité Parisienne SARL",
    siret: "79856234120987",
    legal_form: "SARL",
    contact_name: "Marie Leclerc",
    contact_email: "m.leclerc@elec-paris.fr",
    contact_phone: "01 42 33 44 55",
    city: "Paris",
    postal_code: "75011",
    specialization: "Électricité générale",
    status: "active",
    kyc_status: "validated",
    company_size: "pme",
    credit_limit_eur: 300_000,
    annual_revenue: 1_800_000,
    employee_count: 22,
    registration_date: 3.years.ago,
    iban: "FR7612345678901234567890123",
    logo_url: "https://via.placeholder.com/150/ff6600/ffffff?text=EP"
  },
  {
    company_name: "Plomberie du Sud-Ouest",
    siret: "82345678901234",
    legal_form: "SARL",
    contact_name: "Pierre Martin",
    contact_email: "contact@plomberie-so.fr",
    contact_phone: "05 56 78 90 12",
    city: "Bordeaux",
    postal_code: "33000",
    specialization: "Plomberie et chauffage",
    status: "active",
    kyc_status: "in_progress",
    company_size: "tpe",
    credit_limit_eur: 150_000,
    annual_revenue: 850_000,
    employee_count: 12,
    registration_date: 2.years.ago,
    iban: "FR7698765432109876543210987",
    logo_url: "https://via.placeholder.com/150/00cc66/ffffff?text=PSO"
  },
  {
    company_name: "Menuiserie Artisanale de Provence",
    siret: "81234567890123",
    legal_form: "EURL",
    contact_name: "Sophie Bernard",
    contact_email: "s.bernard@menuiserie-provence.fr",
    contact_phone: "04 91 23 45 67",
    city: "Marseille",
    postal_code: "13008",
    specialization: "Menuiserie bois et aluminium",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 200_000,
    annual_revenue: 1_200_000,
    employee_count: 15,
    registration_date: 7.years.ago,
    iban: "FR7611223344556677889900112",
    logo_url: "https://via.placeholder.com/150/996633/ffffff?text=MAP"
  },
  {
    company_name: "Travaux Publics Nord",
    siret: "83456789012345",
    legal_form: "SAS",
    contact_name: "Laurent Dubois",
    contact_email: "l.dubois@tp-nord.fr",
    contact_phone: "03 20 12 34 56",
    city: "Lille",
    postal_code: "59000",
    specialization: "Terrassement et VRD",
    status: "active",
    kyc_status: "pending",
    company_size: "pme",
    credit_limit_eur: 400_000,
    annual_revenue: 3_200_000,
    employee_count: 45,
    registration_date: 8.years.ago,
    iban: "FR7622334455667788990011223",
    logo_url: "https://via.placeholder.com/150/cc0000/ffffff?text=TPN"
  }
]

companies = companies_data.map { |data| Company.create!(data) }

puts "✅ #{companies.count} entreprises créées"

puts "\n🏗️ Création des chantiers..."

projects_data = [
  {
    project_name: "Construction École Primaire Jean Moulin - Villeurbanne",
    contracting_authority: "Métropole de Lyon",
    contracting_authority_type: "local_authority",
    project_type: "Bâtiment public",
    location: "Villeurbanne (69)",
    total_budget_eur: 2_800_000,
    start_date: 8.months.ago,
    expected_end_date: 4.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 65
  },
  {
    project_name: "Rénovation Hôpital Saint-Antoine - Paris 12ème",
    contracting_authority: "AP-HP (Assistance Publique - Hôpitaux de Paris)",
    contracting_authority_type: "public_establishment",
    project_type: "Établissement de santé",
    location: "Paris 12ème (75)",
    total_budget_eur: 5_500_000,
    start_date: 1.year.ago,
    expected_end_date: 8.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 45
  },
  {
    project_name: "Extension Mairie de Bordeaux",
    contracting_authority: "Ville de Bordeaux",
    contracting_authority_type: "local_authority",
    project_type: "Bâtiment administratif",
    location: "Bordeaux (33)",
    total_budget_eur: 1_200_000,
    start_date: 5.months.ago,
    expected_end_date: 7.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 30
  },
  {
    project_name: "Construction Résidence Seniors 'Les Oliviers' - Aix-en-Provence",
    contracting_authority: "Groupe Immobilier Provence",
    contracting_authority_type: "private",
    project_type: "Logement collectif",
    location: "Aix-en-Provence (13)",
    total_budget_eur: 3_800_000,
    start_date: 10.months.ago,
    expected_end_date: 2.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 80
  },
  {
    project_name: "Aménagement Voirie Avenue Foch - Lille",
    contracting_authority: "Ville de Lille",
    contracting_authority_type: "local_authority",
    project_type: "Travaux publics",
    location: "Lille (59)",
    total_budget_eur: 950_000,
    start_date: 3.months.ago,
    expected_end_date: 5.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 40
  }
]

projects = projects_data.map { |data| Project.create!(data) }

puts "✅ #{projects.count} chantiers créés"

puts "\n👷 Création des participants aux chantiers..."

# Projet 1: École Jean Moulin
ProjectParticipant.create!([
  {
    project: projects[0],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 1_800_000,
    retention_guarantee_rate: 5,
    work_scope: "Gros œuvre et structure"
  },
  {
    project: projects[0],
    company: companies[1], # Électricité Parisienne
    role: "subcontractor",
    contract_amount_eur: 450_000,
    retention_guarantee_rate: 5,
    work_scope: "Installation électrique complète"
  },
  {
    project: projects[0],
    company: companies[2], # Plomberie du Sud-Ouest
    role: "subcontractor",
    contract_amount_eur: 350_000,
    retention_guarantee_rate: 5,
    work_scope: "Plomberie, sanitaires et chauffage"
  }
])

# Projet 2: Hôpital Saint-Antoine
ProjectParticipant.create!([
  {
    project: projects[1],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 3_500_000,
    retention_guarantee_rate: 5,
    work_scope: "Rénovation structure et enveloppe"
  },
  {
    project: projects[1],
    company: companies[1], # Électricité Parisienne
    role: "subcontractor",
    contract_amount_eur: 1_200_000,
    retention_guarantee_rate: 5,
    work_scope: "Systèmes électriques hospitaliers"
  }
])

# Projet 3: Mairie de Bordeaux
ProjectParticipant.create!([
  {
    project: projects[2],
    company: companies[0], # Bâtiments Modernes
    role: "prime_contractor",
    contract_amount_eur: 750_000,
    retention_guarantee_rate: 5,
    work_scope: "Extension bâtiment et maîtrise d'œuvre"
  },
  {
    project: projects[2],
    company: companies[3], # Menuiserie Artisanale
    role: "subcontractor",
    contract_amount_eur: 280_000,
    retention_guarantee_rate: 5,
    work_scope: "Menuiseries extérieures et intérieures"
  }
])

# Projet 4: Résidence Les Oliviers
ProjectParticipant.create!([
  {
    project: projects[3],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 2_400_000,
    retention_guarantee_rate: 3,
    work_scope: "Construction résidence seniors"
  },
  {
    project: projects[3],
    company: companies[3], # Menuiserie Artisanale
    role: "subcontractor",
    contract_amount_eur: 650_000,
    retention_guarantee_rate: 3,
    work_scope: "Menuiseries et aménagements"
  }
])

# Projet 5: Voirie Lille
ProjectParticipant.create!([
  {
    project: projects[4],
    company: companies[4], # Travaux Publics Nord
    role: "general_contractor",
    contract_amount_eur: 850_000,
    retention_guarantee_rate: 5,
    work_scope: "Terrassement et enrobés"
  }
])

puts "✅ #{ProjectParticipant.count} participants créés"

puts "\n📄 Création des factures..."

invoices = []

# Factures pour École Jean Moulin (Projet 1)
# Bâtiments Modernes
invoices << Invoice.create!(
  company: companies[0],
  project: projects[0],
  invoice_number: "FAC-2024-001",
  invoice_type: "acompte",
  invoice_date: 7.months.ago,
  due_date: 6.months.ago + 15.days,
  amount_ht: 300_000,
  vat_amount: 60_000,
  amount_ttc: 360_000,
  payment_status: "paid",
  paid_at: 6.months.ago + 10.days,
  description: "Acompte 20% - Fondations et démarrage gros œuvre",
  chorus_pro_status: "paid_chorus",
  chorus_pro_id: "CP-2024-001-LYO",
  document_url: "https://docs.example.com/fac-2024-001.pdf"
)

invoices << Invoice.create!(
  company: companies[0],
  project: projects[0],
  invoice_number: "FAC-2024-015",
  invoice_type: "situation",
  invoice_date: 3.months.ago,
  due_date: 2.months.ago + 15.days,
  amount_ht: 450_000,
  vat_amount: 90_000,
  amount_ttc: 540_000,
  payment_status: "paid",
  paid_at: 2.months.ago + 12.days,
  description: "Situation 40% - Élévation murs et structure",
  chorus_pro_status: "paid_chorus",
  chorus_pro_id: "CP-2024-015-LYO",
  document_url: "https://docs.example.com/fac-2024-015.pdf"
)

invoices << Invoice.create!(
  company: companies[0],
  project: projects[0],
  invoice_number: "FAC-2024-047",
  invoice_type: "situation",
  invoice_date: 2.weeks.ago,
  due_date: 1.month.from_now + 15.days,
  amount_ht: 250_000,
  vat_amount: 50_000,
  amount_ttc: 300_000,
  payment_status: "pending",
  description: "Situation 65% - Couverture et cloisonnement",
  chorus_pro_status: "validated",
  chorus_pro_id: "CP-2024-047-LYO",
  document_url: "https://docs.example.com/fac-2024-047.pdf"
)

# Électricité Parisienne
invoices << Invoice.create!(
  company: companies[1],
  project: projects[0],
  invoice_number: "EP-2024-032",
  invoice_type: "situation",
  invoice_date: 1.month.ago,
  due_date: 15.days.from_now,
  amount_ht: 180_000,
  vat_amount: 36_000,
  amount_ttc: 216_000,
  payment_status: "pending",
  description: "Situation 40% - Installation électrique",
  chorus_pro_status: "submitted",
  chorus_pro_id: "CP-2024-032-LYO",
  document_url: "https://docs.example.com/ep-2024-032.pdf"
)

# Plomberie du Sud-Ouest
invoices << Invoice.create!(
  company: companies[2],
  project: projects[0],
  invoice_number: "PSO-2024-018",
  invoice_type: "acompte",
  invoice_date: 3.months.ago,
  due_date: 2.months.ago + 15.days,
  amount_ht: 70_000,
  vat_amount: 14_000,
  amount_ttc: 84_000,
  payment_status: "paid",
  paid_at: 2.months.ago + 18.days,
  description: "Acompte 20% - Plomberie et chauffage",
  chorus_pro_status: "paid_chorus",
  chorus_pro_id: "CP-2024-018-LYO"
)

# Factures pour Hôpital Saint-Antoine (Projet 2)
invoices << Invoice.create!(
  company: companies[0],
  project: projects[1],
  invoice_number: "FAC-2024-008",
  invoice_type: "acompte",
  invoice_date: 11.months.ago,
  due_date: 10.months.ago + 15.days,
  amount_ht: 700_000,
  vat_amount: 140_000,
  amount_ttc: 840_000,
  payment_status: "paid",
  paid_at: 10.months.ago + 20.days,
  description: "Acompte 20% - Démarrage rénovation structure",
  chorus_pro_status: "paid_chorus",
  chorus_pro_id: "CP-2024-008-PAR"
)

invoices << Invoice.create!(
  company: companies[0],
  project: projects[1],
  invoice_number: "FAC-2024-035",
  invoice_type: "situation",
  invoice_date: 3.weeks.ago,
  due_date: 1.week.from_now,
  amount_ht: 875_000,
  vat_amount: 175_000,
  amount_ttc: 1_050_000,
  payment_status: "pending",
  description: "Situation 45% - Rénovation enveloppe et façades",
  chorus_pro_status: "validated",
  chorus_pro_id: "CP-2024-035-PAR"
)

invoices << Invoice.create!(
  company: companies[1],
  project: projects[1],
  invoice_number: "EP-2024-041",
  invoice_type: "situation",
  invoice_date: 1.week.ago,
  due_date: 1.month.from_now + 7.days,
  amount_ht: 360_000,
  vat_amount: 72_000,
  amount_ttc: 432_000,
  payment_status: "pending",
  description: "Situation 30% - Installation électrique médicale",
  chorus_pro_status: "submitted",
  chorus_pro_id: "CP-2024-041-PAR"
)

# Factures pour Mairie de Bordeaux (Projet 3)
invoices << Invoice.create!(
  company: companies[0],
  project: projects[2],
  invoice_number: "FAC-2024-028",
  invoice_type: "acompte",
  invoice_date: 4.months.ago,
  due_date: 3.months.ago + 15.days,
  amount_ht: 225_000,
  vat_amount: 45_000,
  amount_ttc: 270_000,
  payment_status: "paid",
  paid_at: 3.months.ago + 25.days,
  description: "Acompte 30% - Extension mairie",
  chorus_pro_status: "paid_chorus",
  chorus_pro_id: "CP-2024-028-BDX"
)

# Factures pour Résidence Les Oliviers (Projet 4)
invoices << Invoice.create!(
  company: companies[0],
  project: projects[3],
  invoice_number: "FAC-2024-012",
  invoice_type: "situation",
  invoice_date: 4.months.ago,
  due_date: 3.months.ago + 15.days,
  amount_ht: 1_600_000,
  vat_amount: 320_000,
  amount_ttc: 1_920_000,
  payment_status: "paid",
  paid_at: 3.months.ago + 10.days,
  description: "Situation 80% - Construction résidence seniors",
  chorus_pro_status: nil,
  chorus_pro_id: nil
)

invoices << Invoice.create!(
  company: companies[3],
  project: projects[3],
  invoice_number: "MAP-2024-007",
  invoice_type: "situation",
  invoice_date: 2.months.ago,
  due_date: 1.month.ago + 15.days,
  amount_ht: 390_000,
  vat_amount: 78_000,
  amount_ttc: 468_000,
  payment_status: "paid",
  paid_at: 1.month.ago + 12.days,
  description: "Situation 60% - Menuiseries résidence",
  chorus_pro_status: nil,
  chorus_pro_id: nil
)

# Factures en retard
invoices << Invoice.create!(
  company: companies[2],
  project: projects[0],
  invoice_number: "PSO-2024-025",
  invoice_type: "situation",
  invoice_date: 2.months.ago,
  due_date: 1.month.ago,
  amount_ht: 105_000,
  vat_amount: 21_000,
  amount_ttc: 126_000,
  payment_status: "overdue",
  description: "Situation 30% - Plomberie sanitaires",
  chorus_pro_status: "validated",
  chorus_pro_id: "CP-2024-025-LYO"
)

puts "✅ #{invoices.count} factures créées"

puts "\n💰 Création des opérations d'affacturage..."

factoring_operations = []

# Opérations complétées
factoring_operations << FactoringOperation.create!(
  company: companies[0],
  invoice: invoices[1], # FAC-2024-015
  invoice_amount: 540_000,
  advance_rate: 90,
  advance_amount: 486_000,
  fee_rate: 1.5,
  fee_amount: 8_100,
  net_amount: 477_900,
  status: "completed",
  approved_by: "Marie Faktus",
  approved_at: 3.months.ago,
  funded_at: 3.months.ago + 1.day,
  final_payment_at: 2.months.ago + 12.days,
  documents_received: true,
  risk_score: 25
)

factoring_operations << FactoringOperation.create!(
  company: companies[0],
  invoice: invoices[5], # FAC-2024-008
  invoice_amount: 840_000,
  advance_rate: 90,
  advance_amount: 756_000,
  fee_rate: 1.5,
  fee_amount: 12_600,
  net_amount: 743_400,
  status: "completed",
  approved_by: "Marie Faktus",
  approved_at: 11.months.ago,
  funded_at: 11.months.ago + 1.day,
  final_payment_at: 10.months.ago + 20.days,
  documents_received: true,
  risk_score: 20
)

# Opérations en cours (funded)
factoring_operations << FactoringOperation.create!(
  company: companies[0],
  invoice: invoices[2], # FAC-2024-047
  invoice_amount: 300_000,
  advance_rate: 90,
  advance_amount: 270_000,
  fee_rate: 1.5,
  fee_amount: 4_500,
  net_amount: 265_500,
  status: "funded",
  approved_by: "Marie Faktus",
  approved_at: 2.weeks.ago,
  funded_at: 2.weeks.ago + 1.day,
  documents_received: true,
  risk_score: 30
)

factoring_operations << FactoringOperation.create!(
  company: companies[0],
  invoice: invoices[6], # FAC-2024-035
  invoice_amount: 1_050_000,
  advance_rate: 90,
  advance_amount: 945_000,
  fee_rate: 1.5,
  fee_amount: 15_750,
  net_amount: 929_250,
  status: "funded",
  approved_by: "Pierre Faktus",
  approved_at: 3.weeks.ago,
  funded_at: 3.weeks.ago + 1.day,
  documents_received: true,
  risk_score: 35
)

# Opérations en attente d'approbation
factoring_operations << FactoringOperation.create!(
  company: companies[1],
  invoice: invoices[3], # EP-2024-032
  invoice_amount: 216_000,
  advance_rate: 90,
  advance_amount: 194_400,
  fee_rate: 1.8,
  fee_amount: 3_888,
  net_amount: 190_512,
  status: "under_review",
  documents_received: true,
  risk_score: 45
)

factoring_operations << FactoringOperation.create!(
  company: companies[1],
  invoice: invoices[7], # EP-2024-041
  invoice_amount: 432_000,
  advance_rate: 90,
  advance_amount: 388_800,
  fee_rate: 1.8,
  fee_amount: 7_776,
  net_amount: 381_024,
  status: "pending",
  documents_received: false,
  risk_score: 50
)

# Opération rejetée
factoring_operations << FactoringOperation.create!(
  company: companies[2],
  invoice: invoices[11], # PSO-2024-025 (en retard)
  invoice_amount: 126_000,
  advance_rate: 90,
  advance_amount: 113_400,
  fee_rate: 2.0,
  fee_amount: 2_520,
  net_amount: 110_880,
  status: "rejected",
  documents_received: false,
  risk_score: 75,
  rejection_reason: "Facture en retard de paiement, risque trop élevé"
)

puts "✅ #{factoring_operations.count} opérations d'affacturage créées"

puts "\n🛡️ Création des garanties de retenue..."

retention_guarantees = []

# Garanties actives
ProjectParticipant.find_each do |participant|
  next if participant.retention_guarantee_amount_eur.nil?

  retention_guarantees << RetentionGuarantee.create!(
    company: participant.company,
    project_participant: participant,
    guarantee_amount: participant.retention_guarantee_amount_eur,
    guarantee_type: "retention",
    issue_date: participant.project.start_date + 1.month,
    release_date: participant.project.expected_end_date + 1.year,
    beneficiary: participant.project.contracting_authority,
    annual_fee_rate: 0.8,
    status: "active",
    contract_reference: "RG-#{participant.project.id}-#{participant.company.id}-2024"
  )
end

puts "✅ #{retention_guarantees.count} garanties de retenue créées"

puts "\n💳 Création des transactions..."

# Transactions pour les opérations d'affacturage complétées
factoring_operations.select(&:status_completed?).each do |operation|
  # Avance initiale (crédit)
  balance_before = operation.company.account_balance
  AccountTransaction.create_factoring_advance!(
    company: operation.company,
    factoring_operation: operation,
    amount: operation.net_amount,
    balance_before: balance_before
  )
end

# Transactions pour les opérations d'affacturage en cours (funded)
factoring_operations.select(&:status_funded?).each do |operation|
  balance_before = operation.company.account_balance
  AccountTransaction.create_factoring_advance!(
    company: operation.company,
    factoring_operation: operation,
    amount: operation.net_amount,
    balance_before: balance_before
  )
end

# Frais de garanties
retention_guarantees.first(3).each do |guarantee|
  balance_before = guarantee.company.account_balance
  AccountTransaction.create_guarantee_fee!(
    company: guarantee.company,
    retention_guarantee: guarantee,
    amount: guarantee.fee_amount || 1000,
    balance_before: balance_before
  )
end

puts "✅ #{AccountTransaction.count} transactions créées"

puts "\n" + "=" * 60
puts "✅ BASE DE DONNÉES INITIALISÉE AVEC SUCCÈS!"
puts "=" * 60
puts "\n📊 Récapitulatif:"
puts "  • #{Company.count} entreprises"
puts "  • #{Project.count} chantiers"
puts "  • #{ProjectParticipant.count} participants"
puts "  • #{Invoice.count} factures"
puts "  • #{FactoringOperation.count} opérations d'affacturage"
puts "  • #{RetentionGuarantee.count} garanties de retenue"
puts "  • #{AccountTransaction.count} transactions"
puts "\n💡 Status des opérations:"
puts "  • Affacturage complété: #{FactoringOperation.completed_operations.count}"
puts "  • Affacturage en cours: #{FactoringOperation.active.count}"
puts "  • Affacturage en attente: #{FactoringOperation.pending_approval.count}"
puts "  • Factures en retard: #{Invoice.overdue.count}"
puts "  • Garanties actives: #{RetentionGuarantee.active.count}"
puts "\n🎯 Prêt pour la démo Faktus!"
puts "=" * 60
