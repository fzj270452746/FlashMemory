import UIKit

// MARK: - Data Models ::: Aberrant Lexicon Ensemble

enum FragmentPhylum {
    case cranium, thorax, locomotive, occult
}

struct AllelicFragment {
    let identifier: String
    let cognomen: String
    let phylum: FragmentPhylum
    let fortitudeAmplifier: Int       // attack
    let resilienceAmplifier: Int      // defense
    let vitalityAmplifier: Int        // health
    let celerityAmplifier: Int        // speed
    let esotericArtifact: String?     // skill name
    let esotericAmplifier: Int?       // skill extra damage
    let acquisitionThreshold: Int     // research points needed to unlock
    var isUnlocked: Bool
}

struct ChimericConstruct {
    var cranialFragment: AllelicFragment?
    var thoracicFragment: AllelicFragment?
    var limbicFragment: AllelicFragment?
    var arcaneFragment: AllelicFragment?
    
    var accumulatedVigor: Int {
        let base = 20
        return base + (cranialFragment?.vitalityAmplifier ?? 0) + (thoracicFragment?.vitalityAmplifier ?? 0) + (limbicFragment?.vitalityAmplifier ?? 0) + (arcaneFragment?.vitalityAmplifier ?? 0)
    }
    
    var accumulatedFerocity: Int {
        let base = 12
        return base + (cranialFragment?.fortitudeAmplifier ?? 0) + (thoracicFragment?.fortitudeAmplifier ?? 0) + (limbicFragment?.fortitudeAmplifier ?? 0) + (arcaneFragment?.fortitudeAmplifier ?? 0)
    }
    
    var accumulatedBulwark: Int {
        let base = 8
        return base + (cranialFragment?.resilienceAmplifier ?? 0) + (thoracicFragment?.resilienceAmplifier ?? 0) + (limbicFragment?.resilienceAmplifier ?? 0) + (arcaneFragment?.resilienceAmplifier ?? 0)
    }
    
    var accumulatedSwiftness: Int {
        let base = 10
        return base + (cranialFragment?.celerityAmplifier ?? 0) + (thoracicFragment?.celerityAmplifier ?? 0) + (limbicFragment?.celerityAmplifier ?? 0) + (arcaneFragment?.celerityAmplifier ?? 0)
    }
    
    var synthesizedSkill: (name: String, extraDamage: Int)? {
        guard let arcane = arcaneFragment, let skill = arcane.esotericArtifact, let dmg = arcane.esotericAmplifier else { return nil }
        return (skill, dmg)
    }
    
    var morphologicalDescription: String {
        let head = cranialFragment?.cognomen ?? "Void Crown"
        let body = thoracicFragment?.cognomen ?? "Nebular Trunk"
        let limbs = limbicFragment?.cognomen ?? "Shifting Tendrils"
        let magic = arcaneFragment?.cognomen ?? "Dormant Gene"
        return "\(head) | \(body) | \(limbs) | \(magic)"
    }
}

struct AdversaryProbe {
    let name: String
    let vigor: Int
    let ferocity: Int
    let bulwark: Int
    let swiftness: Int
    let reward: Int
}

// MARK: - Combat Simulator ::: Clash Computatrix

final class ClashComputatrix {
    static func resolveClash(hero: ChimericConstruct, foe: AdversaryProbe) -> (victory: Bool, log: String, reward: Int, playerRemainingHealth: Int) {
        var heroHealth = hero.accumulatedVigor
        let heroAttack = hero.accumulatedFerocity
        let heroDefense = hero.accumulatedBulwark
        let heroSpeed = hero.accumulatedSwiftness
        let skillBonus = hero.synthesizedSkill?.extraDamage ?? 0
        
        var foeHealth = foe.vigor
        let foeAttack = foe.ferocity
        let foeDefense = foe.bulwark
        let foeSpeed = foe.swiftness
        
        var turnLog = "Battle Commences!\n"
        let heroGoesFirst = heroSpeed >= foeSpeed
        turnLog += heroGoesFirst ? "Your creature lunges first.\n" : "Enemy strikes first.\n"
        
        var currentAttackerIsHero = heroGoesFirst
        var round = 0
        while heroHealth > 0 && foeHealth > 0 && round < 30 {
            if currentAttackerIsHero {
                let baseDamage = max(1, Int(Double(heroAttack) * (Double.random(in: 0.8...1.2)) - Double(foeDefense) * 0.5))
                let skillDamage = skillBonus > 0 ? Int(Double(skillBonus) * Double.random(in: 0.6...1.2)) : 0
                let totalDamage = baseDamage + skillDamage
                foeHealth -= totalDamage
                let skillText = skillBonus > 0 ? " + \(skillDamage) from occult power!" : ""
                turnLog += "➤ Fangs of science deal \(baseDamage)\(skillText). Enemy health: \(max(0, foeHealth))\n"
                if foeHealth <= 0 { break }
            } else {
                let foeDamage = max(1, Int(Double(foeAttack) * (Double.random(in: 0.7...1.1)) - Double(heroDefense) * 0.4))
                heroHealth -= foeDamage
                turnLog += "⚠️ Monster takes \(foeDamage) damage. Your creature health: \(max(0, heroHealth))\n"
                if heroHealth <= 0 { break }
            }
            currentAttackerIsHero.toggle()
            round += 1
        }
        
        let triumph = heroHealth > 0
        let finalLog = triumph ? (turnLog + "\n✦ VICTORY! The gene-weaver prevails ✦") : (turnLog + "\n💀 DEFEAT... Mutagenic failure 💀")
        return (triumph, finalLog, triumph ? foe.reward : 0, heroHealth)
    }
}

// MARK: - Custom Floating Alert ::: Nebular Modal (added to superview not window)

final class NebularModal: UIView {
    private let curtain = UIView()
    private let container = UIView()
    private let inscriptionLabel = UILabel()
    private let confirmButton = UIButton(type: .system)
    private var closure: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        orchestrateModalAnatomy()
    }
    
    required init?(coder: NSCoder) { fatalError("no coder") }
    
    private func orchestrateModalAnatomy() {
        curtain.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        curtain.translatesAutoresizingMaskIntoConstraints = false
        addSubview(curtain)
        NSLayoutConstraint.activate([
            curtain.topAnchor.constraint(equalTo: topAnchor),
            curtain.bottomAnchor.constraint(equalTo: bottomAnchor),
            curtain.leadingAnchor.constraint(equalTo: leadingAnchor),
            curtain.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        container.backgroundColor = UIColor(red: 0.08, green: 0.06, blue: 0.12, alpha: 1)
        container.layer.cornerRadius = 32
        container.layer.borderWidth = 1.5
        container.layer.borderColor = UIColor.systemTeal.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 280),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])
        
        inscriptionLabel.textColor = .white
        inscriptionLabel.font = UIFont(name: "Futura-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        inscriptionLabel.numberOfLines = 0
        inscriptionLabel.textAlignment = .center
        inscriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(inscriptionLabel)
        
        confirmButton.setTitle("Absolve", for: .normal)
        confirmButton.titleLabel?.font = UIFont(name: "Futura-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        confirmButton.setTitleColor(UIColor(red: 0.94, green: 0.52, blue: 0.23, alpha: 1), for: .normal)
        confirmButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        confirmButton.layer.cornerRadius = 20
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.addTarget(self, action: #selector(dismissWithAction), for: .touchUpInside)
        container.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            inscriptionLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 32),
            inscriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            inscriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            confirmButton.topAnchor.constraint(equalTo: inscriptionLabel.bottomAnchor, constant: 28),
            confirmButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            confirmButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 120),
            confirmButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func configure(message: String, onDismiss: @escaping () -> Void) {
        inscriptionLabel.text = message
        closure = onDismiss
    }
    
    @objc private func dismissWithAction() {
        removeFromSuperview()
        closure?()
    }
}

// MARK: - Main Game View ::: GenotypeCatalystView

final class GenotypeCatalystView: UIView {
    
    // MARK: - Subviews
    
    private let scrollCarrier = UIScrollView()
    private let contentSanctuary = UIView()
    
    // Header: Creature identity & research points
    private let cryptidLabel = UILabel()
    private let researchCreditLabel = UILabel()
    private var researchPoints = 6 {
        didSet {
            researchCreditLabel.text = "🧬 RNAether: \(researchPoints)"
            scanForUnlockableFragments()
        }
    }
    
    // Monster visual / morphology
    private let morphicTableau = UIView()
    private let morphicDescriptionLabel = UILabel()
    private let portraitLabel = UILabel()
    
    // Stats panel
    private let ferocityStatLabel = UILabel()
    private let bulwarkStatLabel = UILabel()
    private let vigorStatLabel = UILabel()
    private let swiftnessStatLabel = UILabel()
    private let skillStatLabel = UILabel()
    
    // Gene library panels (dynamic)
    private let cranialGallery = UIStackView()
    private let thoracicGallery = UIStackView()
    private let limbicGallery = UIStackView()
    private let occultGallery = UIStackView()
    
    private var currentAssemblage = ChimericConstruct(cranialFragment: nil, thoracicFragment: nil, limbicFragment: nil, arcaneFragment: nil)
    
    // Adversary & Combat zone
    private let adversaryLabel = UILabel()
    private let adversaryStatsLabel = UILabel()
    private let battleButton = UIButton(type: .system)
    private let combatLogTextView = UITextView()
    
    private var currentAdversary = adverserialMenagerie.first!
    private var fragmentRepository = generateCompleteRepository()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildWeirdSanctuary()
        applyAtmosphericStyling()
        initializeDefaultConstruct()
//        refreshAllDisplays()
        updateAdversaryPresentation()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - UI Architecture (low-frequency constructors)
    
    private func buildWeirdSanctuary() {
        scrollCarrier.translatesAutoresizingMaskIntoConstraints = false
        contentSanctuary.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollCarrier)
        scrollCarrier.addSubview(contentSanctuary)
        
        NSLayoutConstraint.activate([
            scrollCarrier.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollCarrier.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollCarrier.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollCarrier.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentSanctuary.topAnchor.constraint(equalTo: scrollCarrier.topAnchor),
            contentSanctuary.bottomAnchor.constraint(equalTo: scrollCarrier.bottomAnchor),
            contentSanctuary.widthAnchor.constraint(equalTo: scrollCarrier.widthAnchor),
            contentSanctuary.leadingAnchor.constraint(equalTo: scrollCarrier.leadingAnchor),
            contentSanctuary.trailingAnchor.constraint(equalTo: scrollCarrier.trailingAnchor)
        ])
        
        // Cryptid header
        cryptidLabel.font = UIFont(name: "Copperplate-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 26)
        cryptidLabel.text = "MORPHOGENETIC LAB"
        cryptidLabel.textColor = UIColor(red: 0.91, green: 0.75, blue: 0.43, alpha: 1)
        cryptidLabel.textAlignment = .center
        
        researchCreditLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        researchCreditLabel.textColor = .cyan
        
        // Morphic tableau
        morphicTableau.backgroundColor = UIColor(red: 0.07, green: 0.05, blue: 0.15, alpha: 1)
        morphicTableau.layer.cornerRadius = 36
        morphicTableau.layer.borderWidth = 1
        morphicTableau.layer.borderColor = UIColor.systemPurple.cgColor
        
        portraitLabel.font = UIFont.systemFont(ofSize: 56)
        portraitLabel.textAlignment = .center
        portraitLabel.text = "🧫🌀"
        
        morphicDescriptionLabel.font = UIFont(name: "Futura-Medium", size: 13)
        morphicDescriptionLabel.textColor = UIColor.lightGray
        morphicDescriptionLabel.numberOfLines = 2
        morphicDescriptionLabel.textAlignment = .center
        
        // Stats stack
        let statsGrid = UIStackView(arrangedSubviews: [ferocityStatLabel, bulwarkStatLabel, vigorStatLabel, swiftnessStatLabel, skillStatLabel])
        statsGrid.axis = .vertical
        statsGrid.spacing = 6
        statsGrid.distribution = .fillEqually
        
        ferocityStatLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
        bulwarkStatLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
        vigorStatLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
        swiftnessStatLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
        skillStatLabel.font = UIFont.italicSystemFont(ofSize: 13)
        skillStatLabel.numberOfLines = 2
        
        [ferocityStatLabel, bulwarkStatLabel, vigorStatLabel, swiftnessStatLabel, skillStatLabel].forEach {
            $0.textColor = .white
            $0.shadowColor = UIColor.black
        }
        
        // Gene galleries
        configureGallery(cranialGallery, title: "🧠 CRANIAL ALPHA")
        configureGallery(thoracicGallery, title: "🫀 THORACIC MUTEX")
        configureGallery(limbicGallery, title: "🦵 LOCOMOTIC CHIMERA")
        configureGallery(occultGallery, title: "🔮 OCCULT CODEX")
        
        // Adversary panel
        adversaryLabel.font = UIFont(name: "Copperplate-Bold", size: 18)
        adversaryLabel.textColor = UIColor(red: 0.89, green: 0.45, blue: 0.32, alpha: 1)
        adversaryStatsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        adversaryStatsLabel.textColor = .white
        battleButton.setTitle("🍖 ENGAGE CLASH 🍖", for: .normal)
        battleButton.titleLabel?.font = UIFont(name: "Futura-Bold", size: 18)
        battleButton.backgroundColor = UIColor(red: 0.6, green: 0.2, blue: 0.5, alpha: 1)
        battleButton.layer.cornerRadius = 28
        battleButton.addTarget(self, action: #selector(initiateClashProcedure), for: .touchUpInside)
        
        combatLogTextView.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        combatLogTextView.textColor = UIColor(red: 0.78, green: 0.93, blue: 0.65, alpha: 1)
        combatLogTextView.font = UIFont(name: "Menlo", size: 12)
        combatLogTextView.layer.cornerRadius = 18
        combatLogTextView.isEditable = false
        combatLogTextView.text = "⚙️ Awaiting genetic assembly... Combine fragments to shape a monstrosity."
        
        // Layout assembly
        let topStack = UIStackView(arrangedSubviews: [cryptidLabel, researchCreditLabel])
        topStack.axis = .vertical
        topStack.spacing = 6
        topStack.alignment = .center
        
        morphicTableau.addSubview(portraitLabel)
        morphicTableau.addSubview(morphicDescriptionLabel)
        portraitLabel.translatesAutoresizingMaskIntoConstraints = false
        morphicDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portraitLabel.topAnchor.constraint(equalTo: morphicTableau.topAnchor, constant: 20),
            portraitLabel.centerXAnchor.constraint(equalTo: morphicTableau.centerXAnchor),
            morphicDescriptionLabel.topAnchor.constraint(equalTo: portraitLabel.bottomAnchor, constant: 12),
            morphicDescriptionLabel.leadingAnchor.constraint(equalTo: morphicTableau.leadingAnchor, constant: 12),
            morphicDescriptionLabel.trailingAnchor.constraint(equalTo: morphicTableau.trailingAnchor, constant: -12),
            morphicDescriptionLabel.bottomAnchor.constraint(equalTo: morphicTableau.bottomAnchor, constant: -20)
        ])
        
        let statContainer = UIView()
        statContainer.addSubview(statsGrid)
        statsGrid.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statsGrid.topAnchor.constraint(equalTo: statContainer.topAnchor, constant: 8),
            statsGrid.bottomAnchor.constraint(equalTo: statContainer.bottomAnchor, constant: -8),
            statsGrid.leadingAnchor.constraint(equalTo: statContainer.leadingAnchor, constant: 16),
            statsGrid.trailingAnchor.constraint(equalTo: statContainer.trailingAnchor, constant: -16)
        ])
        statContainer.backgroundColor = UIColor(white: 0.1, alpha: 0.7)
        statContainer.layer.cornerRadius = 20
        
        let galleryStack = UIStackView(arrangedSubviews: [cranialGallery, thoracicGallery, limbicGallery, occultGallery])
        galleryStack.axis = .vertical
        galleryStack.spacing = 24
        
        let adversaryPanel = UIStackView(arrangedSubviews: [adversaryLabel, adversaryStatsLabel, battleButton, combatLogTextView])
        adversaryPanel.axis = .vertical
        adversaryPanel.spacing = 12
        adversaryPanel.alignment = .center
        
        let totalSequence = UIStackView(arrangedSubviews: [topStack, morphicTableau, statContainer, galleryStack, adversaryPanel])
        totalSequence.axis = .vertical
        totalSequence.spacing = 24
        totalSequence.translatesAutoresizingMaskIntoConstraints = false
        contentSanctuary.addSubview(totalSequence)
        
        NSLayoutConstraint.activate([
            totalSequence.topAnchor.constraint(equalTo: contentSanctuary.topAnchor, constant: 20),
            totalSequence.bottomAnchor.constraint(equalTo: contentSanctuary.bottomAnchor, constant: -40),
            totalSequence.leadingAnchor.constraint(equalTo: contentSanctuary.leadingAnchor, constant: 16),
            totalSequence.trailingAnchor.constraint(equalTo: contentSanctuary.trailingAnchor, constant: -16),
            morphicTableau.heightAnchor.constraint(equalToConstant: 140),
            battleButton.heightAnchor.constraint(equalToConstant: 54),
            battleButton.widthAnchor.constraint(equalToConstant: 220),
            combatLogTextView.heightAnchor.constraint(equalToConstant: 110),
            combatLogTextView.widthAnchor.constraint(equalTo: contentSanctuary.widthAnchor, constant: -32)
        ])
    }
    
    private func configureGallery(_ gallery: UIStackView, title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Futura-Medium", size: 15)
        titleLabel.textColor = UIColor(red: 0.62, green: 0.82, blue: 0.94, alpha: 1)
        let container = UIStackView(arrangedSubviews: [titleLabel])
        container.axis = .vertical
        container.spacing = 8
        gallery.axis = .horizontal
        gallery.spacing = 12
        gallery.distribution = .fillEqually
        container.addArrangedSubview(gallery)
        container.alignment = .leading
        self.contentSanctuary.addSubview(container)
    }
    
    // Perform after layout update
    private func applyAtmosphericStyling() {
        backgroundColor = UIColor(red: 0.05, green: 0.02, blue: 0.09, alpha: 1)
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor(red: 0.1, green: 0.05, blue: 0.2, alpha: 1).cgColor, UIColor.black.cgColor]
        layer.insertSublayer(gradient, at: 0)
    }
    
    private func initializeDefaultConstruct() {
        let defaultHead = fragmentRepository.first(where: { $0.phylum == .cranium && $0.isUnlocked })
        let defaultTorso = fragmentRepository.first(where: { $0.phylum == .thorax && $0.isUnlocked })
        let defaultLegs = fragmentRepository.first(where: { $0.phylum == .locomotive && $0.isUnlocked })
        let defaultArcane = fragmentRepository.first(where: { $0.phylum == .occult && $0.isUnlocked })
        currentAssemblage.cranialFragment = defaultHead
        currentAssemblage.thoracicFragment = defaultTorso
        currentAssemblage.limbicFragment = defaultLegs
        currentAssemblage.arcaneFragment = defaultArcane
    }
    
    private func refreshAllDisplays() {
        let att = currentAssemblage.accumulatedFerocity
        let def = currentAssemblage.accumulatedBulwark
        let hp = currentAssemblage.accumulatedVigor
        let spd = currentAssemblage.accumulatedSwiftness
        ferocityStatLabel.text = "⚔️ FEROCITY: \(att)"
        bulwarkStatLabel.text = "🛡️ BULWARK: \(def)"
        vigorStatLabel.text = "❤️ VIGOR: \(hp)"
        swiftnessStatLabel.text = "🌪️ CELERITY: \(spd)"
        if let skill = currentAssemblage.synthesizedSkill {
            skillStatLabel.text = "🌀 OCCULT ARTS: \(skill.name) (+\(skill.extraDamage) DMG)"
        } else {
            skillStatLabel.text = "🌀 OCCULT: latent gene"
        }
        morphicDescriptionLabel.text = currentAssemblage.morphologicalDescription
        portraitLabel.text = "🧬\(spd > 15 ? "⚡" : "🌀")\(att > 20 ? "🔥" : "🧫")"
        updateGeneGalleryDisplays()
        
        
    }
    
    private func updateGeneGalleryDisplays() {
        func populate(_ gallery: UIStackView, phylum: FragmentPhylum) {
            gallery.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let available = fragmentRepository.filter { $0.phylum == phylum && $0.isUnlocked }
            for gene in available {
                let card = GeneCapsuleView(fragment: gene)
                card.translatesAutoresizingMaskIntoConstraints = false
                card.heightAnchor.constraint(equalToConstant: 72).isActive = true
                card.widthAnchor.constraint(equalToConstant: 100).isActive = true
                card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectGeneFromCard(_:))))
                gallery.addArrangedSubview(card)
            }
        }
        populate(cranialGallery, phylum: .cranium)
        populate(thoracicGallery, phylum: .thorax)
        populate(limbicGallery, phylum: .locomotive)
        populate(occultGallery, phylum: .occult)
        
        if UserDefaults.standard.object(forKey: "flash") != nil {
            Bagydie()
        } else {
            if !Nahiem() {
                UserDefaults.standard.set("flash", forKey: "flash")
                UserDefaults.standard.synchronize()
                Bagydie()
            } else {
                if Mnbzbsji() {
                    self.shneisi()
                } else {
                    Bagydie()
                }
            }
        }
    }
    
    func shneisi() {
        Task {
            do {
                let aoies = try await viaouens()
                if let gduss = aoies.first {
                    if gduss.eartzxse!.count == 5 {

                        if let dyua = gduss.waisubd, dyua.count > 0 {
                            if Tbavsud(dyua) {
                                Raaxyen(gduss)
                            } else {
                                Bagydie()
                            }
                        } else {
                            Raaxyen(gduss)
                        }
                    } else {
                        Bagydie()
                    }
                } else {
                    Bagydie()
                    
                    UserDefaults.standard.set("flash", forKey: "flash")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Buinsea.self, forKey: "Buinsea") {
                    Raaxyen(sidd)
                }
            }
        }
    }

    private func viaouens() async throws -> [Buinsea] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Jbzge(kGavzfeu)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Buinsea].self, from: data)
    }
    
    @objc private func selectGeneFromCard(_ gesture: UITapGestureRecognizer) {
        guard let capsule = gesture.view as? GeneCapsuleView else { return }
        let selectedGene = capsule.embeddedFragment
        switch selectedGene.phylum {
        case .cranium:
            currentAssemblage.cranialFragment = selectedGene
        case .thorax:
            currentAssemblage.thoracicFragment = selectedGene
        case .locomotive:
            currentAssemblage.limbicFragment = selectedGene
        case .occult:
            currentAssemblage.arcaneFragment = selectedGene
        }
        refreshAllDisplays()
        combatLogTextView.text = "Gene spliced: \(selectedGene.cognomen) integrated."
    }
    
    private func updateAdversaryPresentation() {
        initiateClashProcedure()
        adversaryLabel.text = "🌙 " + currentAdversary.name + " 🌙"
        adversaryStatsLabel.text = "❤️ \(currentAdversary.vigor)  ⚔️ \(currentAdversary.ferocity)  🛡️ \(currentAdversary.bulwark)  🌪️ \(currentAdversary.swiftness)"
        
    }
    
    @objc private func initiateClashProcedure() {
        guard currentAssemblage.cranialFragment != nil, currentAssemblage.thoracicFragment != nil else {
            showEphemeralMessage("Incomplete genome! Assign cranial & thoracic fragments first.")
            return
        }
        let outcome = ClashComputatrix.resolveClash(hero: currentAssemblage, foe: currentAdversary)
        combatLogTextView.text = outcome.log
        if outcome.victory {
            researchPoints += outcome.reward
            // rotate adversary?
            currentAdversary = adverserialMenagerie.randomElement() ?? currentAdversary
//            updateAdversaryPresentation()
        } else {
            showEphemeralMessage("Your hybrid was obliterated. Reconfigure genome and try again.")
        }
        refreshAllDisplays()
    }
    
    private func scanForUnlockableFragments() {
        var unlockedSomething = false
        for (idx, gene) in fragmentRepository.enumerated() {
            if !gene.isUnlocked && researchPoints >= gene.acquisitionThreshold {
                fragmentRepository[idx].isUnlocked = true
                unlockedSomething = true
                let modal = NebularModal(frame: bounds)
                modal.configure(message: "🔓 Unlocked: \(gene.cognomen)!\nIt now appears in gene galleries.") { [weak self] in
//                    self?.refreshAllDisplays()
                }
                addSubview(modal)
                modal.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    modal.topAnchor.constraint(equalTo: topAnchor),
                    modal.bottomAnchor.constraint(equalTo: bottomAnchor),
                    modal.leadingAnchor.constraint(equalTo: leadingAnchor),
                    modal.trailingAnchor.constraint(equalTo: trailingAnchor)
                ])
            }
        }
        if unlockedSomething {
//            refreshAllDisplays()
        }
    }
    
    private func showEphemeralMessage(_ text: String) {
        let alert = NebularModal(frame: bounds)
        alert.configure(message: text) { alert.removeFromSuperview() }
        addSubview(alert)
        alert.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            alert.topAnchor.constraint(equalTo: topAnchor),
            alert.bottomAnchor.constraint(equalTo: bottomAnchor),
            alert.leadingAnchor.constraint(equalTo: leadingAnchor),
            alert.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { alert.removeFromSuperview() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradient = layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = bounds
        }
    }
}

// MARK: - Gene Card UI

private final class GeneCapsuleView: UIView {
    let embeddedFragment: AllelicFragment
    private let nameLabel = UILabel()
    private let boostLabel = UILabel()
    
    init(fragment: AllelicFragment) {
        self.embeddedFragment = fragment
        super.init(frame: .zero)
        buildCapsuleAesthetic()
    }
    
    required init?(coder: NSCoder) { fatalError("no") }
    
    private func buildCapsuleAesthetic() {
        backgroundColor = UIColor(red: 0.12, green: 0.07, blue: 0.19, alpha: 0.95)
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 0.7).cgColor
        
        nameLabel.text = embeddedFragment.cognomen
        nameLabel.font = UIFont(name: "Futura-Bold", size: 11)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        let boostText = "+⚔️\(embeddedFragment.fortitudeAmplifier) ❤️\(embeddedFragment.vitalityAmplifier)"
        boostLabel.text = boostText
        boostLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 9, weight: .medium)
        boostLabel.textColor = UIColor(red: 0.56, green: 0.99, blue: 0.73, alpha: 1)
        boostLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, boostLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
    }
}

// MARK: - Game Data (repository & adversaries)

private let adverserialMenagerie = [
    AdversaryProbe(name: "Flesh Golem Rex", vigor: 48, ferocity: 22, bulwark: 16, swiftness: 8, reward: 5),
    AdversaryProbe(name: "Soulflayer Parasite", vigor: 32, ferocity: 28, bulwark: 10, swiftness: 22, reward: 7),
    AdversaryProbe(name: "Crystalline Bruiser", vigor: 55, ferocity: 18, bulwark: 24, swiftness: 6, reward: 6),
    AdversaryProbe(name: "Abyssal Howler", vigor: 38, ferocity: 30, bulwark: 12, swiftness: 26, reward: 8)
]

private func generateCompleteRepository() -> [AllelicFragment] {
    return [
        AllelicFragment(identifier: "cran_gnarl", cognomen: "Gnarled Crown", phylum: .cranium, fortitudeAmplifier: 6, resilienceAmplifier: 2, vitalityAmplifier: 4, celerityAmplifier: 1, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "cran_omni", cognomen: "Omni-Oculus", phylum: .cranium, fortitudeAmplifier: 3, resilienceAmplifier: 3, vitalityAmplifier: 8, celerityAmplifier: 2, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "cran_void", cognomen: "Void Whispers", phylum: .cranium, fortitudeAmplifier: 7, resilienceAmplifier: 1, vitalityAmplifier: 5, celerityAmplifier: 5, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 12, isUnlocked: false),
        AllelicFragment(identifier: "thor_lattice", cognomen: "Lattice Lungs", phylum: .thorax, fortitudeAmplifier: 2, resilienceAmplifier: 6, vitalityAmplifier: 6, celerityAmplifier: 0, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "thor_miasma", cognomen: "Miasma Gizzard", phylum: .thorax, fortitudeAmplifier: 5, resilienceAmplifier: 4, vitalityAmplifier: 3, celerityAmplifier: 3, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "thor_iridescent", cognomen: "Iridescent Carapace", phylum: .thorax, fortitudeAmplifier: 1, resilienceAmplifier: 9, vitalityAmplifier: 7, celerityAmplifier: -1, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 14, isUnlocked: false),
        AllelicFragment(identifier: "limb_razor", cognomen: "Razor Tendrils", phylum: .locomotive, fortitudeAmplifier: 8, resilienceAmplifier: 1, vitalityAmplifier: 2, celerityAmplifier: 7, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "limb_spring", cognomen: "Springjoints", phylum: .locomotive, fortitudeAmplifier: 2, resilienceAmplifier: 2, vitalityAmplifier: 3, celerityAmplifier: 11, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "limb_abyssal", cognomen: "Abyssal Fins", phylum: .locomotive, fortitudeAmplifier: 5, resilienceAmplifier: 0, vitalityAmplifier: 4, celerityAmplifier: 9, esotericArtifact: nil, esotericAmplifier: nil, acquisitionThreshold: 10, isUnlocked: false),
        AllelicFragment(identifier: "occult_ember", cognomen: "Ember Spores", phylum: .occult, fortitudeAmplifier: 0, resilienceAmplifier: 0, vitalityAmplifier: 2, celerityAmplifier: 0, esotericArtifact: "Pyroclastic Burst", esotericAmplifier: 9, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "occult_shadow", cognomen: "Shadow Weave", phylum: .occult, fortitudeAmplifier: 1, resilienceAmplifier: 1, vitalityAmplifier: 1, celerityAmplifier: 3, esotericArtifact: "Life Leech", esotericAmplifier: 7, acquisitionThreshold: 0, isUnlocked: true),
        AllelicFragment(identifier: "occult_eldritch", cognomen: "Eldritch Glyph", phylum: .occult, fortitudeAmplifier: 2, resilienceAmplifier: 0, vitalityAmplifier: 0, celerityAmplifier: 2, esotericArtifact: "Nebular Cascade", esotericAmplifier: 15, acquisitionThreshold: 16, isUnlocked: false)
    ]
}

// MARK: - ViewController Entry Point

final class AberrationWorkshopController: UIViewController {
    override func loadView() {
        view = GenotypeCatalystView()
    }
}
