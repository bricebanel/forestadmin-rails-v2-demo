# encoding: utf-8

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
  },
  {
    company_name: "Couverture Toulousaine",
    siret: "84567890123456",
    legal_form: "SARL",
    contact_name: "Antoine Rousseau",
    contact_email: "a.rousseau@couverture-toulouse.fr",
    contact_phone: "05 61 11 22 33",
    city: "Toulouse",
    postal_code: "31000",
    specialization: "Couverture et étanchéité",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 180_000,
    annual_revenue: 950_000,
    employee_count: 14,
    registration_date: 4.years.ago,
    iban: "FR7633445566778899001122334",
    logo_url: "https://via.placeholder.com/150/9933cc/ffffff?text=CT"
  },
  {
    company_name: "Peinture et Décoration Nantaise",
    siret: "85678901234567",
    legal_form: "EURL",
    contact_name: "Isabelle Moreau",
    contact_email: "i.moreau@peinture-nantes.fr",
    contact_phone: "02 40 55 66 77",
    city: "Nantes",
    postal_code: "44000",
    specialization: "Peinture et revêtements",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 120_000,
    annual_revenue: 680_000,
    employee_count: 9,
    registration_date: 3.years.ago,
    iban: "FR7644556677889900112233445",
    logo_url: "https://via.placeholder.com/150/ff9900/ffffff?text=PDN"
  },
  {
    company_name: "Maçonnerie Bretonne",
    siret: "86789012345678",
    legal_form: "SARL",
    contact_name: "Yves Le Goff",
    contact_email: "y.legoff@maconnerie-bretagne.fr",
    contact_phone: "02 98 77 88 99",
    city: "Rennes",
    postal_code: "35000",
    specialization: "Maçonnerie générale",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 250_000,
    annual_revenue: 1_400_000,
    employee_count: 18,
    registration_date: 6.years.ago,
    iban: "FR7655667788990011223344556",
    logo_url: "https://via.placeholder.com/150/006699/ffffff?text=MB"
  },
  {
    company_name: "Chauffage Climatisation Strasbourg",
    siret: "87890123456789",
    legal_form: "SAS",
    contact_name: "Thomas Schmidt",
    contact_email: "t.schmidt@clim-strasbourg.fr",
    contact_phone: "03 88 99 00 11",
    city: "Strasbourg",
    postal_code: "67000",
    specialization: "CVC et climatisation",
    status: "active",
    kyc_status: "validated",
    company_size: "pme",
    credit_limit_eur: 350_000,
    annual_revenue: 2_100_000,
    employee_count: 28,
    registration_date: 5.years.ago,
    iban: "FR7666778899001122334455667",
    logo_url: "https://via.placeholder.com/150/00ccff/ffffff?text=CCS"
  },
  {
    company_name: "Métallerie Lyonnaise",
    siret: "88901234567890",
    legal_form: "SARL",
    contact_name: "François Girard",
    contact_email: "f.girard@metallerie-lyon.fr",
    contact_phone: "04 72 33 44 55",
    city: "Lyon",
    postal_code: "69003",
    specialization: "Métallerie et serrurerie",
    status: "active",
    kyc_status: "in_progress",
    company_size: "tpe",
    credit_limit_eur: 160_000,
    annual_revenue: 780_000,
    employee_count: 11,
    registration_date: 3.years.ago,
    iban: "FR7677889900112233445566778",
    logo_url: "https://via.placeholder.com/150/cc6600/ffffff?text=ML"
  },
  {
    company_name: "Ascenseurs et Élévateurs du Rhône",
    siret: "89012345678901",
    legal_form: "SAS",
    contact_name: "Caroline Faure",
    contact_email: "c.faure@ascenseurs-rhone.fr",
    contact_phone: "04 78 11 22 33",
    city: "Lyon",
    postal_code: "69001",
    specialization: "Installation d'ascenseurs",
    status: "active",
    kyc_status: "validated",
    company_size: "pme",
    credit_limit_eur: 450_000,
    annual_revenue: 2_800_000,
    employee_count: 32,
    registration_date: 9.years.ago,
    iban: "FR7688990011223344556677889",
    logo_url: "https://via.placeholder.com/150/9900cc/ffffff?text=AER"
  },
  {
    company_name: "Carrelage et Faïence Méditerranée",
    siret: "80123456789012",
    legal_form: "EURL",
    contact_name: "Nicolas Blanc",
    contact_email: "n.blanc@carrelage-med.fr",
    contact_phone: "04 93 44 55 66",
    city: "Nice",
    postal_code: "06000",
    specialization: "Carrelage et revêtements sols",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 140_000,
    annual_revenue: 720_000,
    employee_count: 10,
    registration_date: 4.years.ago,
    iban: "FR7699001122334455667788990",
    logo_url: "https://via.placeholder.com/150/33cc99/ffffff?text=CFM"
  },
  {
    company_name: "Charpente Bois Aquitaine",
    siret: "81234509876543",
    legal_form: "SARL",
    contact_name: "Julien Dumas",
    contact_email: "j.dumas@charpente-aquitaine.fr",
    contact_phone: "05 57 22 33 44",
    city: "Bordeaux",
    postal_code: "33200",
    specialization: "Charpente et ossature bois",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 220_000,
    annual_revenue: 1_150_000,
    employee_count: 16,
    registration_date: 7.years.ago,
    iban: "FR7600112233445566778899001",
    logo_url: "https://via.placeholder.com/150/663300/ffffff?text=CBA"
  },
  {
    company_name: "Isolation Thermique Écologique",
    siret: "82345098765432",
    legal_form: "SAS",
    contact_name: "Émilie Garnier",
    contact_email: "e.garnier@isolation-eco.fr",
    contact_phone: "04 75 66 77 88",
    city: "Valence",
    postal_code: "26000",
    specialization: "Isolation thermique et phonique",
    status: "active",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 190_000,
    annual_revenue: 920_000,
    employee_count: 13,
    registration_date: 3.years.ago,
    iban: "FR7611223344556677889900223",
    logo_url: "https://via.placeholder.com/150/99cc00/ffffff?text=ITE"
  },
  {
    company_name: "Démolition Terrassement Parisien",
    siret: "83456098765421",
    legal_form: "SARL",
    contact_name: "Marc Chevalier",
    contact_email: "m.chevalier@demolition-paris.fr",
    contact_phone: "01 48 55 66 77",
    city: "Paris",
    postal_code: "75019",
    specialization: "Démolition et terrassement",
    status: "suspended",
    kyc_status: "pending",
    company_size: "pme",
    credit_limit_eur: 0,
    annual_revenue: 2_600_000,
    employee_count: 38,
    registration_date: 10.years.ago,
    iban: "FR7622334455667788990011334",
    logo_url: "https://via.placeholder.com/150/cc0033/ffffff?text=DTP"
  },
  {
    company_name: "Vitrerie Miroiterie Moderne",
    siret: "84567098765410",
    legal_form: "EURL",
    contact_name: "Sandrine Petit",
    contact_email: "s.petit@vitrerie-moderne.fr",
    contact_phone: "01 49 88 99 00",
    city: "Paris",
    postal_code: "75015",
    specialization: "Vitrerie et miroiterie",
    status: "closed",
    kyc_status: "validated",
    company_size: "tpe",
    credit_limit_eur: 0,
    annual_revenue: 580_000,
    employee_count: 0,
    registration_date: 5.years.ago,
    iban: "FR7633445566778899001122445",
    logo_url: "https://via.placeholder.com/150/00cccc/ffffff?text=VMM"
  },
  # === TEST COMPANIES FOR ONBOARDING DEMO ===
  {
    company_name: "Construction Verte Durable",
    siret: "95678123456789",
    legal_form: "SAS",
    contact_name: "Julie Martin",
    contact_email: "j.martin@construction-verte.fr",
    contact_phone: "01 55 66 77 88",
    address: "45 Avenue de la République",
    city: "Lyon",
    postal_code: "69003",
    specialization: "Construction écologique",
    status: "active",
    kyc_status: "in_progress",
    company_size: "pme",
    credit_limit_eur: 200_000,
    annual_revenue: 2_800_000,
    employee_count: 45,
    registration_date: 8.years.ago,
    iban: "FR7644556677889900112233556",
    logo_url: "https://via.placeholder.com/150/00aa44/ffffff?text=CVD"
  },
  {
    company_name: "Rénovation Express Plus",
    siret: "96789234567890",
    legal_form: "SARL",
    contact_name: "Thomas Dubois",
    contact_email: "t.dubois@renovation-express.fr",
    contact_phone: "01 56 77 88 99",
    address: "12 Rue du Commerce",
    city: "Marseille",
    postal_code: "13002",
    specialization: "Rénovation bâtiments",
    status: "active",
    kyc_status: "pending",
    company_size: "pme",
    credit_limit_eur: 350_000,
    annual_revenue: 1_500_000,
    employee_count: 18,
    registration_date: 4.years.ago,
    iban: "FR7655667788990011223344667",
    logo_url: "https://via.placeholder.com/150/ff6600/ffffff?text=REP"
  },
  {
    company_name: "Maçonnerie Artisanale Moderne",
    siret: "97890345678901",
    legal_form: "EURL",
    contact_name: "Pierre Moreau",
    contact_email: "p.moreau@maconnerie-moderne.fr",
    contact_phone: "01 57 88 99 00",
    address: "78 Boulevard Victor Hugo",
    city: "Toulouse",
    postal_code: "31000",
    specialization: "Maçonnerie générale",
    status: "active",
    kyc_status: "in_progress",
    company_size: "tpe",
    credit_limit_eur: 100_000,
    annual_revenue: 450_000,
    employee_count: 6,
    registration_date: 2.years.ago,
    iban: "FR7766778899001122334455778",
    logo_url: "https://via.placeholder.com/150/cc6600/ffffff?text=MAM"
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
    project_name: "Construction Nouveau Tribunal de Grande Instance - Versailles",
    contracting_authority: "Ministère de la Justice",
    contracting_authority_type: "state",
    project_type: "Bâtiment judiciaire",
    location: "Versailles (78)",
    total_budget_eur: 12_500_000,
    start_date: 18.months.ago,
    expected_end_date: 6.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 70
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
    start_date: 14.months.ago,
    expected_end_date: 2.months.ago,
    actual_end_date: 3.weeks.ago,
    status: "completed",
    progress_percentage: 100
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
  },
  {
    project_name: "Construction Crèche Municipale - Nantes",
    contracting_authority: "Ville de Nantes",
    contracting_authority_type: "local_authority",
    project_type: "Bâtiment public",
    location: "Nantes (44)",
    total_budget_eur: 1_500_000,
    start_date: 6.months.ago,
    expected_end_date: 6.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 50
  },
  {
    project_name: "Rénovation Médiathèque Jean Jaurès - Toulouse",
    contracting_authority: "Toulouse Métropole",
    contracting_authority_type: "local_authority",
    project_type: "Bâtiment culturel",
    location: "Toulouse (31)",
    total_budget_eur: 2_200_000,
    start_date: 13.months.ago,
    expected_end_date: 2.months.ago,
    actual_end_date: 6.weeks.ago,
    status: "completed",
    progress_percentage: 100
  },
  {
    project_name: "Construction Gymnase Lycée Victor Hugo - Marseille",
    contracting_authority: "Région Provence-Alpes-Côte d'Azur",
    contracting_authority_type: "local_authority",
    project_type: "Équipement sportif",
    location: "Marseille (13)",
    total_budget_eur: 1_800_000,
    start_date: 7.months.ago,
    expected_end_date: 5.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 55
  },
  {
    project_name: "Réhabilitation Immeuble de Bureaux - Strasbourg",
    contracting_authority: "SCI Strasbourg Centre",
    contracting_authority_type: "private",
    project_type: "Bâtiment tertiaire",
    location: "Strasbourg (67)",
    total_budget_eur: 3_200_000,
    start_date: 11.months.ago,
    expected_end_date: 1.month.from_now,
    actual_end_date: nil,
    status: "suspended",
    progress_percentage: 90
  },
  {
    project_name: "Construction Parking Souterrain - Lyon Part-Dieu",
    contracting_authority: "Métropole de Lyon",
    contracting_authority_type: "local_authority",
    project_type: "Infrastructure",
    location: "Lyon (69)",
    total_budget_eur: 4_500_000,
    start_date: 1.year.ago + 2.months,
    expected_end_date: 10.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 35
  },
  {
    project_name: "Rénovation énergétique Groupe Scolaire - Rennes",
    contracting_authority: "Ville de Rennes",
    contracting_authority_type: "local_authority",
    project_type: "Bâtiment public",
    location: "Rennes (35)",
    total_budget_eur: 1_100_000,
    start_date: 4.months.ago,
    expected_end_date: 8.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 25
  },
  {
    project_name: "Construction Centre Commercial Les Arcades - Nice",
    contracting_authority: "Foncière Azur Développement",
    contracting_authority_type: "private",
    project_type: "Bâtiment commercial",
    location: "Nice (06)",
    total_budget_eur: 8_900_000,
    start_date: 1.year.ago + 4.months,
    expected_end_date: 1.year.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 40
  },
  {
    project_name: "Aménagement Zone d'Activités - Valence",
    contracting_authority: "Communauté d'Agglomération Valence Romans",
    contracting_authority_type: "local_authority",
    project_type: "Travaux publics",
    location: "Valence (26)",
    total_budget_eur: 2_700_000,
    start_date: nil,
    expected_end_date: 18.months.from_now,
    actual_end_date: nil,
    status: "planned",
    progress_percentage: 0
  },
  {
    project_name: "Construction Résidence Étudiants Campus - Bordeaux",
    contracting_authority: "CROUS Nouvelle-Aquitaine",
    contracting_authority_type: "public_establishment",
    project_type: "Logement collectif",
    location: "Bordeaux (33)",
    total_budget_eur: 6_200_000,
    start_date: 1.year.ago,
    expected_end_date: 6.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 60
  },
  {
    project_name: "Rénovation Façades Immeuble Haussmannien - Paris 8ème",
    contracting_authority: "Syndicat de Copropriété Avenue Montaigne",
    contracting_authority_type: "private",
    project_type: "Ravalement de façade",
    location: "Paris (75)",
    total_budget_eur: 850_000,
    start_date: 3.months.ago,
    expected_end_date: 3.months.from_now,
    actual_end_date: nil,
    status: "in_progress",
    progress_percentage: 45
  },
  {
    project_name: "Construction Piscine Olympique - Montpellier",
    contracting_authority: "Ville de Montpellier",
    contracting_authority_type: "local_authority",
    project_type: "Équipement sportif",
    location: "Montpellier (34)",
    total_budget_eur: 9_500_000,
    start_date: nil,
    expected_end_date: 2.years.from_now,
    actual_end_date: nil,
    status: "planned",
    progress_percentage: 0
  }
]

projects = projects_data.map { |data| Project.create!(data) }

puts "✅ #{projects.count} chantiers créés"

puts "\n👷 Création des participants aux chantiers..."

participants = []

# Projet 1: École Jean Moulin
participants += ProjectParticipant.create!([
  {
    project: projects[0],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 1_800_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Gros œuvre et structure"
  },
  {
    project: projects[0],
    company: companies[1], # Électricité Parisienne
    role: "subcontractor",
    contract_amount_eur: 450_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Installation électrique complète"
  },
  {
    project: projects[0],
    company: companies[2], # Plomberie du Sud-Ouest
    role: "subcontractor",
    contract_amount_eur: 350_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Plomberie, sanitaires et chauffage"
  }
])

# Projet 2: Hôpital Saint-Antoine
participants += ProjectParticipant.create!([
  {
    project: projects[1],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 3_500_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Rénovation structure et enveloppe"
  },
  {
    project: projects[1],
    company: companies[1], # Électricité Parisienne
    role: "subcontractor",
    contract_amount_eur: 1_200_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Systèmes électriques hospitaliers"
  },
  {
    project: projects[1],
    company: companies[8], # Chauffage Climatisation
    role: "subcontractor",
    contract_amount_eur: 600_000,
    retention_guarantee_rate: 0.05,
    work_scope: "CVC et climatisation médicale"
  }
])

# Projet 3: Mairie de Bordeaux
participants += ProjectParticipant.create!([
  {
    project: projects[2],
    company: companies[0], # Bâtiments Modernes
    role: "prime_contractor",
    contract_amount_eur: 750_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Extension bâtiment et maîtrise d'œuvre"
  },
  {
    project: projects[2],
    company: companies[3], # Menuiserie Artisanale
    role: "subcontractor",
    contract_amount_eur: 280_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Menuiseries extérieures et intérieures"
  }
])

# Projet 4: Résidence Les Oliviers
participants += ProjectParticipant.create!([
  {
    project: projects[3],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 2_400_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Construction résidence seniors"
  },
  {
    project: projects[3],
    company: companies[3], # Menuiserie Artisanale
    role: "subcontractor",
    contract_amount_eur: 650_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Menuiseries et aménagements"
  },
  {
    project: projects[3],
    company: companies[10], # Ascenseurs
    role: "subcontractor",
    contract_amount_eur: 420_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Installation ascenseurs et monte-charges"
  }
])

# Projet 5: Voirie Lille
participants += ProjectParticipant.create!([
  {
    project: projects[4],
    company: companies[4], # Travaux Publics Nord
    role: "general_contractor",
    contract_amount_eur: 850_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Terrassement et enrobés"
  }
])

# Projet 6: Crèche Nantes
participants += ProjectParticipant.create!([
  {
    project: projects[5],
    company: companies[7], # Maçonnerie Bretonne
    role: "general_contractor",
    contract_amount_eur: 950_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Gros œuvre et maçonnerie"
  },
  {
    project: projects[5],
    company: companies[6], # Peinture Nantaise
    role: "subcontractor",
    contract_amount_eur: 180_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Peinture et décoration intérieure"
  }
])

# Projet 7: Médiathèque Toulouse
participants += ProjectParticipant.create!([
  {
    project: projects[6],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 1_400_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Rénovation structure"
  },
  {
    project: projects[6],
    company: companies[5], # Couverture Toulousaine
    role: "subcontractor",
    contract_amount_eur: 320_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Couverture et étanchéité"
  },
  {
    project: projects[6],
    company: companies[13], # Isolation Écologique
    role: "subcontractor",
    contract_amount_eur: 280_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Isolation thermique et acoustique"
  }
])

# Projet 8: Gymnase Marseille
participants += ProjectParticipant.create!([
  {
    project: projects[7],
    company: companies[7], # Maçonnerie Bretonne
    role: "general_contractor",
    contract_amount_eur: 1_100_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Gros œuvre bâtiment sportif"
  },
  {
    project: projects[7],
    company: companies[12], # Charpente Bois
    role: "subcontractor",
    contract_amount_eur: 380_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Charpente bois lamellé-collé"
  }
])

# Projet 9: Bureaux Strasbourg
participants += ProjectParticipant.create!([
  {
    project: projects[8],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 2_000_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Réhabilitation tous corps d'état"
  },
  {
    project: projects[8],
    company: companies[8], # Chauffage Climatisation Strasbourg
    role: "subcontractor",
    contract_amount_eur: 650_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Système CVC bureaux"
  }
])

# Projet 10: Parking Lyon
participants += ProjectParticipant.create!([
  {
    project: projects[9],
    company: companies[4], # Travaux Publics Nord
    role: "general_contractor",
    contract_amount_eur: 3_800_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Terrassement et génie civil"
  },
  {
    project: projects[9],
    company: companies[1], # Électricité Parisienne
    role: "subcontractor",
    contract_amount_eur: 450_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Éclairage et installations électriques"
  }
])

# Projet 11: Groupe Scolaire Rennes
participants += ProjectParticipant.create!([
  {
    project: projects[10],
    company: companies[7], # Maçonnerie Bretonne
    role: "prime_contractor",
    contract_amount_eur: 680_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Rénovation énergétique complète"
  },
  {
    project: projects[10],
    company: companies[13], # Isolation Écologique
    role: "subcontractor",
    contract_amount_eur: 290_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Isolation par l'extérieur"
  }
])

# Projet 12: Centre Commercial Nice
participants += ProjectParticipant.create!([
  {
    project: projects[11],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 5_500_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Construction centre commercial"
  },
  {
    project: projects[11],
    company: companies[11], # Carrelage Méditerranée
    role: "subcontractor",
    contract_amount_eur: 890_000,
    retention_guarantee_rate: 0.03,
    work_scope: "Revêtements sols et murs"
  }
])

# Projet 13: Zone Activités Valence
participants += ProjectParticipant.create!([
  {
    project: projects[12],
    company: companies[14], # Démolition Terrassement
    role: "general_contractor",
    contract_amount_eur: 2_100_000,
    retention_guarantee_rate: 0.05,
    work_scope: "VRD et aménagements"
  }
])

# Projet 14: Résidence Étudiants Bordeaux
participants += ProjectParticipant.create!([
  {
    project: projects[13],
    company: companies[0], # Bâtiments Modernes
    role: "general_contractor",
    contract_amount_eur: 4_200_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Construction résidence 150 logements"
  },
  {
    project: projects[13],
    company: companies[2], # Plomberie Sud-Ouest
    role: "subcontractor",
    contract_amount_eur: 850_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Plomberie et sanitaires"
  }
])

# Projet 15: Façades Paris
participants += ProjectParticipant.create!([
  {
    project: projects[14],
    company: companies[6], # Peinture Nantaise
    role: "general_contractor",
    contract_amount_eur: 520_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Ravalement de façades"
  },
  {
    project: projects[14],
    company: companies[9], # Métallerie Lyonnaise
    role: "subcontractor",
    contract_amount_eur: 180_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Ferronnerie balcons et garde-corps"
  }
])

puts "✅ #{ProjectParticipant.count} participants créés"

puts "\n📄 Création des factures..."

invoices = []

# Factures pour projet École Jean Moulin
invoices << Invoice.create!(
  company: companies[0], project: projects[0], invoice_number: "FAC-2024-001", invoice_type: "acompte",
  invoice_date: 7.months.ago, due_date: 6.months.ago + 15.days, amount_ht: 300_000, vat_amount: 60_000, amount_ttc: 360_000,
  payment_status: "paid", paid_at: 6.months.ago + 10.days, description: "Acompte 20% - Fondations et démarrage gros œuvre",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-001-LYO", document_url: "https://docs.example.com/fac-2024-001.pdf"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[0], invoice_number: "FAC-2024-015", invoice_type: "situation",
  invoice_date: 3.months.ago, due_date: 2.months.ago + 15.days, amount_ht: 450_000, vat_amount: 90_000, amount_ttc: 540_000,
  payment_status: "paid", paid_at: 2.months.ago + 12.days, description: "Situation 40% - Élévation murs et structure",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-015-LYO"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[0], invoice_number: "FAC-2024-047", invoice_type: "situation",
  invoice_date: 2.weeks.ago, due_date: 1.month.from_now + 15.days, amount_ht: 250_000, vat_amount: 50_000, amount_ttc: 300_000,
  payment_status: "pending", description: "Situation 65% - Couverture et cloisonnement",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-047-LYO"
)

invoices << Invoice.create!(
  company: companies[1], project: projects[0], invoice_number: "EP-2024-032", invoice_type: "situation",
  invoice_date: 1.month.ago, due_date: 15.days.from_now, amount_ht: 180_000, vat_amount: 36_000, amount_ttc: 216_000,
  payment_status: "pending", description: "Situation 40% - Installation électrique",
  chorus_pro_status: "submitted", chorus_pro_id: "CP-2024-032-LYO"
)

invoices << Invoice.create!(
  company: companies[2], project: projects[0], invoice_number: "PSO-2024-018", invoice_type: "acompte",
  invoice_date: 3.months.ago, due_date: 2.months.ago + 15.days, amount_ht: 70_000, vat_amount: 14_000, amount_ttc: 84_000,
  payment_status: "paid", paid_at: 2.months.ago + 18.days, description: "Acompte 20% - Plomberie et chauffage",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-018-LYO"
)

# Factures Hôpital Saint-Antoine
invoices << Invoice.create!(
  company: companies[0], project: projects[1], invoice_number: "FAC-2024-008", invoice_type: "acompte",
  invoice_date: 11.months.ago, due_date: 10.months.ago + 15.days, amount_ht: 700_000, vat_amount: 140_000, amount_ttc: 840_000,
  payment_status: "paid", paid_at: 10.months.ago + 20.days, description: "Acompte 20% - Démarrage rénovation structure",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-008-PAR"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[1], invoice_number: "FAC-2024-035", invoice_type: "situation",
  invoice_date: 3.weeks.ago, due_date: 1.week.from_now, amount_ht: 875_000, vat_amount: 175_000, amount_ttc: 1_050_000,
  payment_status: "pending", description: "Situation 45% - Rénovation enveloppe et façades",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-035-PAR"
)

invoices << Invoice.create!(
  company: companies[1], project: projects[1], invoice_number: "EP-2024-041", invoice_type: "situation",
  invoice_date: 1.week.ago, due_date: 1.month.from_now + 7.days, amount_ht: 360_000, vat_amount: 72_000, amount_ttc: 432_000,
  payment_status: "pending", description: "Situation 30% - Installation électrique médicale",
  chorus_pro_status: "submitted", chorus_pro_id: "CP-2024-041-PAR"
)

# Facture Mairie Bordeaux
invoices << Invoice.create!(
  company: companies[0], project: projects[2], invoice_number: "FAC-2024-028", invoice_type: "acompte",
  invoice_date: 4.months.ago, due_date: 3.months.ago + 15.days, amount_ht: 225_000, vat_amount: 45_000, amount_ttc: 270_000,
  payment_status: "paid", paid_at: 3.months.ago + 25.days, description: "Acompte 30% - Extension mairie",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-028-BDX"
)

# Factures Résidence Oliviers
invoices << Invoice.create!(
  company: companies[0], project: projects[3], invoice_number: "FAC-2024-012", invoice_type: "situation",
  invoice_date: 4.months.ago, due_date: 3.months.ago + 15.days, amount_ht: 1_600_000, vat_amount: 320_000, amount_ttc: 1_920_000,
  payment_status: "paid", paid_at: 3.months.ago + 10.days, description: "Situation 80% - Construction résidence seniors"
)

invoices << Invoice.create!(
  company: companies[3], project: projects[3], invoice_number: "MAP-2024-007", invoice_type: "situation",
  invoice_date: 2.months.ago, due_date: 1.month.ago + 15.days, amount_ht: 390_000, vat_amount: 78_000, amount_ttc: 468_000,
  payment_status: "paid", paid_at: 1.month.ago + 12.days, description: "Situation 60% - Menuiseries résidence"
)

# Facture en retard
invoices << Invoice.create!(
  company: companies[2], project: projects[0], invoice_number: "PSO-2024-025", invoice_type: "situation",
  invoice_date: 2.months.ago, due_date: 1.month.ago, amount_ht: 105_000, vat_amount: 21_000, amount_ttc: 126_000,
  payment_status: "overdue", description: "Situation 30% - Plomberie sanitaires",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-025-LYO"
)

# Factures additionnelles pour atteindre 15+
invoices << Invoice.create!(
  company: companies[4], project: projects[4], invoice_number: "TPN-2024-012", invoice_type: "acompte",
  invoice_date: 75.days.ago, due_date: 45.days.ago + 15.days, amount_ht: 170_000, vat_amount: 34_000, amount_ttc: 204_000,
  payment_status: "paid", paid_at: 45.days.ago + 8.days, description: "Acompte 20% - Voirie Avenue Foch",
  chorus_pro_status: "paid_chorus", chorus_pro_id: "CP-2024-012-LILLE"
)

invoices << Invoice.create!(
  company: companies[7], project: projects[5], invoice_number: "MB-2024-033", invoice_type: "situation",
  invoice_date: 3.weeks.ago, due_date: 3.weeks.from_now, amount_ht: 475_000, vat_amount: 95_000, amount_ttc: 570_000,
  payment_status: "pending", description: "Situation 50% - Crèche municipale Nantes",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-033-NTE"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[6], invoice_number: "FAC-2024-052", invoice_type: "situation",
  invoice_date: 1.week.ago, due_date: 5.weeks.from_now, amount_ht: 1_050_000, vat_amount: 210_000, amount_ttc: 1_260_000,
  payment_status: "pending", description: "Situation 75% - Médiathèque Toulouse",
  chorus_pro_status: "submitted", chorus_pro_id: "CP-2024-052-TLS"
)

invoices << Invoice.create!(
  company: companies[7], project: projects[7], invoice_number: "MB-2024-040", invoice_type: "situation",
  invoice_date: 2.weeks.ago, due_date: 4.weeks.from_now, amount_ht: 605_000, vat_amount: 121_000, amount_ttc: 726_000,
  payment_status: "pending", description: "Situation 55% - Gymnase Marseille",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-040-MRS"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[8], invoice_number: "FAC-2024-063", invoice_type: "situation",
  invoice_date: 3.days.ago, due_date: 1.month.from_now + 3.days, amount_ht: 1_800_000, vat_amount: 360_000, amount_ttc: 2_160_000,
  payment_status: "pending", description: "Situation 90% - Immeuble bureaux Strasbourg"
)

invoices << Invoice.create!(
  company: companies[4], project: projects[9], invoice_number: "TPN-2024-021", invoice_type: "situation",
  invoice_date: 5.days.ago, due_date: 5.weeks.from_now, amount_ht: 1_330_000, vat_amount: 266_000, amount_ttc: 1_596_000,
  payment_status: "pending", description: "Situation 35% - Parking souterrain Lyon",
  chorus_pro_status: "submitted", chorus_pro_id: "CP-2024-021-LYO"
)

invoices << Invoice.create!(
  company: companies[0], project: projects[13], invoice_number: "FAC-2024-071", invoice_type: "situation",
  invoice_date: 1.week.ago, due_date: 5.weeks.from_now, amount_ht: 2_520_000, vat_amount: 504_000, amount_ttc: 3_024_000,
  payment_status: "pending", description: "Situation 60% - Résidence étudiants Bordeaux",
  chorus_pro_status: "validated", chorus_pro_id: "CP-2024-071-BDX"
)

invoices << Invoice.create!(
  company: companies[11], project: projects[11], invoice_number: "CFM-2024-015", invoice_type: "situation",
  invoice_date: 4.days.ago, due_date: 1.month.from_now, amount_ht: 356_000, vat_amount: 71_200, amount_ttc: 427_200,
  payment_status: "pending", description: "Situation 40% - Centre commercial Nice"
)

puts "✅ #{invoices.count} factures créées"

puts "\n💰 Création des opérations d'affacturage..."

factoring_operations = []

# Opérations complétées
factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[1], invoice_amount: 540_000,
  advance_rate: 0.90, advance_amount: 486_000, fee_rate: 0.015, fee_amount: 8_100, net_amount: 477_900,
  status: "completed", approved_by: "Marie Faktus", approved_at: 3.months.ago,
  funded_at: 3.months.ago + 1.day, final_payment_at: 2.months.ago + 12.days,
  documents_received: true, risk_score: 25
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[5], invoice_amount: 840_000,
  advance_rate: 0.90, advance_amount: 756_000, fee_rate: 0.015, fee_amount: 12_600, net_amount: 743_400,
  status: "completed", approved_by: "Marie Faktus", approved_at: 11.months.ago,
  funded_at: 11.months.ago + 1.day, final_payment_at: 10.months.ago + 20.days,
  documents_received: true, risk_score: 20
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[8], invoice_amount: 270_000,
  advance_rate: 0.90, advance_amount: 243_000, fee_rate: 0.015, fee_amount: 4_050, net_amount: 238_950,
  status: "completed", approved_by: "Pierre Faktus", approved_at: 4.months.ago,
  funded_at: 4.months.ago + 1.day, final_payment_at: 3.months.ago + 25.days,
  documents_received: true, risk_score: 22
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[9], invoice_amount: 1_920_000,
  advance_rate: 0.85, advance_amount: 1_632_000, fee_rate: 0.012, fee_amount: 23_040, net_amount: 1_608_960,
  status: "completed", approved_by: "Marie Faktus", approved_at: 4.months.ago,
  funded_at: 4.months.ago + 1.day, final_payment_at: 3.months.ago + 10.days,
  documents_received: true, risk_score: 18
)

# Opérations en cours (funded)
factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[2], invoice_amount: 300_000,
  advance_rate: 0.90, advance_amount: 270_000, fee_rate: 0.015, fee_amount: 4_500, net_amount: 265_500,
  status: "funded", approved_by: "Marie Faktus", approved_at: 2.weeks.ago,
  funded_at: 2.weeks.ago + 1.day, documents_received: true, risk_score: 30
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[6], invoice_amount: 1_050_000,
  advance_rate: 0.90, advance_amount: 945_000, fee_rate: 0.015, fee_amount: 15_750, net_amount: 929_250,
  status: "funded", approved_by: "Pierre Faktus", approved_at: 3.weeks.ago,
  funded_at: 3.weeks.ago + 1.day, documents_received: true, risk_score: 35
)

factoring_operations << FactoringOperation.create!(
  company: companies[7], invoice: invoices[13], invoice_amount: 570_000,
  advance_rate: 0.88, advance_amount: 501_600, fee_rate: 0.018, fee_amount: 10_260, net_amount: 491_340,
  status: "funded", approved_by: "Marie Faktus", approved_at: 3.weeks.ago + 2.days,
  funded_at: 3.weeks.ago + 3.days, documents_received: true, risk_score: 38
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[14], invoice_amount: 1_260_000,
  advance_rate: 0.90, advance_amount: 1_134_000, fee_rate: 0.015, fee_amount: 18_900, net_amount: 1_115_100,
  status: "funded", approved_by: "Pierre Faktus", approved_at: 1.week.ago,
  funded_at: 1.week.ago + 1.day, documents_received: true, risk_score: 28
)

# Opérations en attente d'approbation
factoring_operations << FactoringOperation.create!(
  company: companies[1], invoice: invoices[3], invoice_amount: 216_000,
  advance_rate: 0.90, advance_amount: 194_400, fee_rate: 0.018, fee_amount: 3_888, net_amount: 190_512,
  status: "under_review", documents_received: true, risk_score: 45
)

factoring_operations << FactoringOperation.create!(
  company: companies[1], invoice: invoices[7], invoice_amount: 432_000,
  advance_rate: 0.90, advance_amount: 388_800, fee_rate: 0.018, fee_amount: 7_776, net_amount: 381_024,
  status: "pending", documents_received: false, risk_score: 50
)

factoring_operations << FactoringOperation.create!(
  company: companies[7], invoice: invoices[15], invoice_amount: 726_000,
  advance_rate: 0.88, advance_amount: 638_880, fee_rate: 0.018, fee_amount: 13_068, net_amount: 625_812,
  status: "under_review", documents_received: true, risk_score: 42
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[16], invoice_amount: 2_160_000,
  advance_rate: 0.85, advance_amount: 1_836_000, fee_rate: 0.012, fee_amount: 25_920, net_amount: 1_810_080,
  status: "pending", documents_received: true, risk_score: 32
)

factoring_operations << FactoringOperation.create!(
  company: companies[4], invoice: invoices[17], invoice_amount: 1_596_000,
  advance_rate: 0.88, advance_amount: 1_404_480, fee_rate: 0.016, fee_amount: 25_536, net_amount: 1_378_944,
  status: "under_review", documents_received: false, risk_score: 48
)

factoring_operations << FactoringOperation.create!(
  company: companies[0], invoice: invoices[18], invoice_amount: 3_024_000,
  advance_rate: 0.90, advance_amount: 2_721_600, fee_rate: 0.015, fee_amount: 45_360, net_amount: 2_676_240,
  status: "pending", documents_received: true, risk_score: 35
)

# Opération rejetée
factoring_operations << FactoringOperation.create!(
  company: companies[2], invoice: invoices[11], invoice_amount: 126_000,
  advance_rate: 0.90, advance_amount: 113_400, fee_rate: 0.020, fee_amount: 2_520, net_amount: 110_880,
  status: "rejected", documents_received: false, risk_score: 75,
  rejection_reason: "Facture en retard de paiement, risque trop élevé"
)

puts "✅ #{factoring_operations.count} opérations d'affacturage créées"

puts "\n🛡️ Création des garanties de retenue..."

retention_guarantees = []

ProjectParticipant.find_each do |participant|
  next if participant.retention_guarantee_amount_eur.nil?
  next if participant.project.start_date.nil? # Skip planned projects

  retention_guarantees << RetentionGuarantee.create!(
    company: participant.company,
    project_participant: participant,
    guarantee_amount: participant.retention_guarantee_amount_eur,
    guarantee_type: "retention",
    issue_date: participant.project.start_date + 1.month,
    release_date: participant.project.expected_end_date + 1.year,
    beneficiary: participant.project.contracting_authority,
    annual_fee_rate: 0.008,
    status: "active",
    contract_reference: "RG-#{participant.project.id}-#{participant.company.id}-2024"
  )
end

puts "✅ #{retention_guarantees.count} garanties de retenue créées"

puts "\n💳 Création des transactions..."

# Transactions pour les opérations d'affacturage complétées
factoring_operations.select(&:status_completed?).each do |operation|
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
retention_guarantees.first(5).each do |guarantee|
  balance_before = guarantee.company.account_balance
  AccountTransaction.create_guarantee_fee!(
    company: guarantee.company,
    retention_guarantee: guarantee,
    amount: guarantee.fee_amount || 1000,
    balance_before: balance_before
  )
end

puts "✅ #{AccountTransaction.count} transactions créées"
# Additional improvements for variety

# Additional improvements for variety

puts "\n📝 Adding additional variety improvements..."

# Add supplier roles to completed projects (Les Oliviers - project 4)
if projects[3] && companies[11] # Carrelage Méditerranée
  ProjectParticipant.create!(
    project: projects[3],
    company: companies[11],
    role: "supplier",
    contract_amount_eur: 85_000,
    retention_guarantee_rate: nil,
    work_scope: "Fourniture carrelages haut de gamme"
  )
end

# Add specialist role to hospital project
if projects[1] && companies[15] # Vitrerie
  ProjectParticipant.create!(
    project: projects[1],
    company: companies[15],
    role: "specialist",
    contract_amount_eur: 120_000,
    retention_guarantee_rate: 0.05,
    work_scope: "Vitrages spéciaux salles stériles"
  )
end

# Add more invoice types - solde invoices for completed projects
solde_invoices = []

# Solde for completed Oliviers project
if projects[3] && companies[0]
  solde_invoices << Invoice.create!(
    company: companies[0],
    project: projects[3],
    invoice_number: "FAC-2024-080",
    invoice_type: "solde",
    invoice_date: 2.weeks.ago,
    due_date: 1.month.from_now + 15.days,
    amount_ht: 400_000,
    vat_amount: 80_000,
    amount_ttc: 480_000,
    payment_status: "paid",
    paid_at: 1.week.ago,
    description: "Solde final - Résidence Les Oliviers"
  )
end

# Solde for completed Médiathèque
if projects[6] && companies[0]
  solde_invoices << Invoice.create!(
    company: companies[0],
    project: projects[6],
    invoice_number: "FAC-2024-085",
    invoice_type: "solde",
    invoice_date: 5.weeks.ago,
    due_date: 2.weeks.from_now,
    amount_ht: 250_000,
    vat_amount: 50_000,
    amount_ttc: 300_000,
    payment_status: "pending",
    description: "Solde final - Médiathèque Toulouse"
  )
end

# Add avoir (credit note) - COMMENTED OUT due to validation failure with negative amounts
# if projects[0] && companies[0]
#   Invoice.create!(
#     company: companies[0],
#     project: projects[0],
#     invoice_number: "FAC-2024-AV001",
#     invoice_type: "avoir",
#     invoice_date: 1.month.ago,
#     due_date: 1.month.ago,
#     amount_ht: -15_000,
#     vat_amount: -3_000,
#     amount_ttc: -18_000,
#     payment_status: "paid",
#     paid_at: 3.weeks.ago,
#     description: "Avoir - Correction facturation situation 40%",
#     chorus_pro_status: "paid_chorus",
#     chorus_pro_id: "CP-2024-AV001-LYO"
#   )
# end

# Add partially_paid invoices
if projects[9] && companies[1]
  Invoice.create!(
    company: companies[1],
    project: projects[9],
    invoice_number: "EP-2024-055",
    invoice_type: "situation",
    invoice_date: 6.weeks.ago,
    due_date: 3.weeks.ago,
    amount_ht: 225_000,
    vat_amount: 45_000,
    amount_ttc: 270_000,
    payment_status: "partially_paid",
    paid_at: 2.weeks.ago,
    description: "Situation 50% - Éclairage parking (partiellement payée)",
    chorus_pro_status: "validated",
    chorus_pro_id: "CP-2024-055-LYO"
  )
end

# Distribute factoring operations to other companies
more_factoring = []

# Électricité Parisienne
if companies[1] && invoices.find { |i| i.invoice_number == "EP-2024-032" }
  invoice_ep = invoices.find { |i| i.invoice_number == "EP-2024-032" }
  more_factoring << FactoringOperation.create!(
    company: companies[1],
    invoice: invoice_ep,
    invoice_amount: 216_000,
    advance_rate: 0.88,
    advance_amount: 190_080,
    fee_rate: 0.018,
    fee_amount: 3_888,
    net_amount: 186_192,
    status: "funded",
    approved_by: "Marie Faktus",
    approved_at: 1.month.ago + 2.days,
    funded_at: 1.month.ago + 3.days,
    documents_received: true,
    risk_score: 42
  )
end

# Plomberie Sud-Ouest
new_invoice_pso = Invoice.create!(
  company: companies[2],
  project: projects[13],
  invoice_number: "PSO-2024-040",
  invoice_type: "situation",
  invoice_date: 2.weeks.ago,
  due_date: 4.weeks.from_now,
  amount_ht: 425_000,
  vat_amount: 85_000,
  amount_ttc: 510_000,
  payment_status: "pending",
  description: "Situation 50% - Plomberie résidence étudiants",
  chorus_pro_status: "validated",
  chorus_pro_id: "CP-2024-040-BDX"
)

more_factoring << FactoringOperation.create!(
  company: companies[2],
  invoice: new_invoice_pso,
  invoice_amount: 510_000,
  advance_rate: 0.88,
  advance_amount: 448_800,
  fee_rate: 0.019,
  fee_amount: 9_690,
  net_amount: 439_110,
  status: "under_review",
  documents_received: true,
  risk_score: 46
)

# Menuiserie Artisanale
if companies[3] && invoices.find { |i| i.invoice_number == "MAP-2024-007" }
  invoice_map = invoices.find { |i| i.invoice_number == "MAP-2024-007" }
  more_factoring << FactoringOperation.create!(
    company: companies[3],
    invoice: invoice_map,
    invoice_amount: 468_000,
    advance_rate: 0.88,
    advance_amount: 411_840,
    fee_rate: 0.017,
    fee_amount: 7_956,
    net_amount: 403_884,
    status: "completed",
    approved_by: "Pierre Faktus",
    approved_at: 2.months.ago + 3.days,
    funded_at: 2.months.ago + 4.days,
    final_payment_at: 1.month.ago + 12.days,
    documents_received: true,
    risk_score: 28
  )
end

# Travaux Publics Nord
new_invoice_tpn = Invoice.create!(
  company: companies[4],
  project: projects[4],
  invoice_number: "TPN-2024-030",
  invoice_type: "situation",
  invoice_date: 1.week.ago,
  due_date: 5.weeks.from_now,
  amount_ht: 340_000,
  vat_amount: 68_000,
  amount_ttc: 408_000,
  payment_status: "pending",
  description: "Situation 40% - Voirie Lille",
  chorus_pro_status: "submitted",
  chorus_pro_id: "CP-2024-030-LILLE"
)

more_factoring << FactoringOperation.create!(
  company: companies[4],
  invoice: new_invoice_tpn,
  invoice_amount: 408_000,
  advance_rate: 0.90,
  advance_amount: 367_200,
  fee_rate: 0.016,
  fee_amount: 6_528,
  net_amount: 360_672,
  status: "pending",
  documents_received: false,
  risk_score: 38
)

# Chauffage Climatisation Strasbourg
if projects[1] && companies[8]
  new_invoice_ccs = Invoice.create!(
    company: companies[8],
    project: projects[1],
    invoice_number: "CCS-2024-018",
    invoice_type: "situation",
    invoice_date: 10.days.ago,
    due_date: 1.month.from_now + 20.days,
    amount_ht: 240_000,
    vat_amount: 48_000,
    amount_ttc: 288_000,
    payment_status: "pending",
    description: "Situation 40% - CVC hôpital",
    chorus_pro_status: "submitted",
    chorus_pro_id: "CP-2024-018-PAR"
  )
  
  more_factoring << FactoringOperation.create!(
    company: companies[8],
    invoice: new_invoice_ccs,
    invoice_amount: 288_000,
    advance_rate: 0.88,
    advance_amount: 253_440,
    fee_rate: 0.017,
    fee_amount: 4_896,
    net_amount: 248_544,
    status: "under_review",
    documents_received: true,
    risk_score: 40
  )
end

# Add different guarantee types - COMMENTED OUT due to date calculation issues
# different_guarantees = []
#
# # Good performance guarantee
# if ProjectParticipant.find_by(project: projects[2], company: companies[0]) && projects[2].start_date && projects[2].expected_end_date
#   pp = ProjectParticipant.find_by(project: projects[2], company: companies[0])
#   different_guarantees << RetentionGuarantee.create!(
#     company: companies[0],
#     project_participant: pp,
#     guarantee_amount: 150_000,
#     guarantee_type: "good_performance",
#     issue_date: projects[2].start_date,
#     release_date: projects[2].expected_end_date + 6.months,
#     beneficiary: projects[2].contracting_authority,
#     annual_fee_rate: 0.010,
#     status: "active",
#     contract_reference: "GP-#{projects[2].id}-#{companies[0].id}-2024"
#   )
# end
#
# # Advance payment guarantee
# if ProjectParticipant.find_by(project: projects[13], company: companies[0]) && projects[13].start_date && projects[13].expected_end_date
#   pp = ProjectParticipant.find_by(project: projects[13], company: companies[0])
#   different_guarantees << RetentionGuarantee.create!(
#     company: companies[0],
#     project_participant: pp,
#     guarantee_amount: 420_000,
#     guarantee_type: "advance_payment",
#     issue_date: projects[13].start_date,
#     release_date: projects[13].expected_end_date,
#     beneficiary: projects[13].contracting_authority,
#     annual_fee_rate: 0.012,
#     status: "active",
#     contract_reference: "AP-#{projects[13].id}-#{companies[0].id}-2024"
#   )
# end
#
# # Final completion guarantee for completed project
# if ProjectParticipant.find_by(project: projects[3], company: companies[0]) && projects[3].actual_end_date
#   pp = ProjectParticipant.find_by(project: projects[3], company: companies[0])
#   different_guarantees << RetentionGuarantee.create!(
#     company: companies[0],
#     project_participant: pp,
#     guarantee_amount: 72_000,
#     guarantee_type: "final_completion",
#     issue_date: projects[3].actual_end_date - 1.week,
#     release_date: projects[3].actual_end_date + 1.year,
#     beneficiary: projects[3].contracting_authority,
#     annual_fee_rate: 0.008,
#     status: "active",
#     contract_reference: "FC-#{projects[3].id}-#{companies[0].id}-2024"
#   )
# end

# Release some guarantees for completed project (Médiathèque)
# Commenting out due to date calculation issues in callbacks
# if ProjectParticipant.find_by(project: projects[6], company: companies[0]) && projects[6].actual_end_date
#   pp = ProjectParticipant.find_by(project: projects[6], company: companies[0])
#   rg = RetentionGuarantee.find_by(project_participant: pp)
#   if rg
#     rg.update!(status: "released", release_date: projects[6].actual_end_date + 2.weeks)
#   end
# end

# Expire an old guarantee
# Commenting out due to date calculation issues in callbacks
# if ProjectParticipant.find_by(project: projects[6], company: companies[5])
#   pp = ProjectParticipant.find_by(project: projects[6], company: companies[5])
#   rg = RetentionGuarantee.find_by(project_participant: pp)
#   if rg
#     rg.update!(status: "expired", release_date: 1.month.ago)
#   end
# end

# Add more transaction types
additional_transactions = []

# Factoring fees for completed operations
FactoringOperation.where(status: "completed").limit(2).each do |operation|
  balance_before = operation.company.account_balance
  additional_transactions << AccountTransaction.create!(
    company: operation.company,
    transaction_type: "factoring_fee",
    amount: operation.fee_amount,
    direction: "debit",
    balance_after: balance_before - operation.fee_amount,
    transaction_date: operation.funded_at,
    description: "Frais d'affacturage - Facture ##{operation.invoice.invoice_number}",
    reference_type: "FactoringOperation",
    reference_id: operation.id
  )
end

# Factoring completion for completed operations
FactoringOperation.where(status: "completed").limit(2).each do |operation|
  balance_before = operation.company.account_balance
  remaining = operation.invoice_amount - operation.advance_amount
  additional_transactions << AccountTransaction.create!(
    company: operation.company,
    transaction_type: "factoring_completion",
    amount: remaining,
    direction: "credit",
    balance_after: balance_before + remaining,
    transaction_date: operation.final_payment_at,
    description: "Solde final affacturage - Facture ##{operation.invoice.invoice_number}",
    reference_type: "FactoringOperation",
    reference_id: operation.id
  )
end

# Guarantee release
if RetentionGuarantee.where(status: "released").any?
  rg = RetentionGuarantee.where(status: "released").first
  balance_before = rg.company.account_balance
  additional_transactions << AccountTransaction.create!(
    company: rg.company,
    transaction_type: "guarantee_release",
    amount: rg.guarantee_amount,
    direction: "credit",
    balance_after: balance_before + rg.guarantee_amount,
    transaction_date: rg.release_date,
    description: "Libération garantie - #{rg.contract_reference}",
    reference_type: "RetentionGuarantee",
    reference_id: rg.id
  )
end

# Some deposits/withdrawals
[companies[0], companies[1], companies[7]].each do |company|
  balance_before = company.account_balance
  amount = [50_000, 75_000, 100_000].sample
  additional_transactions << AccountTransaction.create!(
    company: company,
    transaction_type: "deposit",
    amount: amount,
    direction: "credit",
    balance_after: balance_before + amount,
    transaction_date: rand(60..90).days.ago,
    description: "Dépôt de fonds"
  )
end

puts "✅ Améliorations de variété ajoutées:"
puts "  • #{ProjectParticipant.where(role: ["supplier", "specialist"]).count} fournisseurs/spécialistes"
puts "  • #{Invoice.where(invoice_type: ["solde"]).count} factures solde"
puts "  • #{Invoice.where(payment_status: "partially_paid").count} factures partiellement payées"
puts "  • #{more_factoring.count} opérations d'affacturage distribuées"
puts "  • #{additional_transactions.count} transactions additionnelles"
