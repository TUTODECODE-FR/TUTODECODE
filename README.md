<p align="center">
  <img src="assets/logo.png" width="96" height="96" alt="TUTODECODE Logo">
</p>

# TUTODECODE — Écosystème IT & Cybersécurité "All-in-One"

[![Dernière Version](https://img.shields.io/github/v/release/TUTODECODE-FR/TUTODECODE?style=for-the-badge&color=indigo&label=v1.0.3%20Stable)](https://github.com/TUTODECODE-FR/TUTODECODE/releases/latest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/TUTODECODE-FR/TUTODECODE/build_release.yml?branch=main&style=for-the-badge&label=BUILD)](https://github.com/TUTODECODE-FR/TUTODECODE/actions/workflows/build_release.yml)
[![Licence](https://img.shields.io/github/license/TUTODECODE-FR/TUTODECODE?style=for-the-badge&color=blue)](https://github.com/TUTODECODE-FR/TUTODECODE/blob/main/LICENSE)

> **"Le savoir technique ne devrait jamais dépendre d'une connexion."**

TUTODECODE est une plateforme d'apprentissage technique et d'outils cybersécurité conçue pour les professionnels de l'IT. Le logiciel fonctionne de manière **100% isolée** pour une souveraineté numérique totale.

---

### 📥 Téléchargements (v1.0.3 Officielle)

| Plateforme | Binaire | Statut |
| :--- | :--- | :--- |
| ![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white) | [**Fichier APK**](https://github.com/TUTODECODE-FR/TUTODECODE/releases/latest/download/TUTODECODE-Android.apk) | `Disponible` |
| ![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white) | [**Installeur EXE**](https://github.com/TUTODECODE-FR/TUTODECODE/releases/latest/download/TUTODECODE-Setup.exe) | `Signé` |
| ![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white) | [**Installateur DMG**](https://github.com/TUTODECODE-FR/TUTODECODE/releases/latest/download/TUTODECODE-macOS.dmg) | `Signé + Notarizé` |
| ![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) | [**Paquet DEB** / **AppImage**](https://github.com/TUTODECODE-FR/TUTODECODE/releases/latest) | `Disponible` |

---

## ⚡ Pourquoi choisir TUTODECODE ?

*   **🛡️ Souveraineté Totale** : Aucune dépendance à des services tiers ou aux clouds. Tout est stocké et exécuté sur votre machine.
*   **📂 Système de Modules** : Importez vos propres contenus de cours au format Markdown/JSON en les glissant simplement dans le dossier `modules`.
*   **🎨 Expérience Premium** : Une interface moderne développée avec **Flutter**, offrant fluidité et lisibilité, même sur les modules les plus complexes.
*   **📜 Agnosticisme Réseau** : Idéal pour les intervenants en datacenter, les environnements "Air-Gapped" ou les zones sans connexion.

## 🤖 Ghost AI (Intelligence 100% Locale)

L'une des pièces maîtresses de TUTODECODE est son intégration avec **Ollama**.
Grâce à ce système, l'application peut faire appel à des LLM (Llama, Mistral, CodeGemma) installés sur votre machine locale pour vous aider directement dans vos cours, sans jamais sortir un seul octet du réseau local.

---

## 🎓 Parcours & Laboratoires

TUTODECODE n'est pas qu'un simple lecteur de cours, c'est un laboratoire d'expérimentation :

*   🖥️ **Systèmes Industriels** : Linux (Kernel, Bash), Docker Hub et Kubernetes Avancé.
*   🛡️ **Cybersécurité Offensive** : OWASP Top 10, diagnostics réseaux, simulateurs de Handshake TCP et Injections SQL.
*   💻 **Développement & Tooling** : Python Professionnel, API REST, Git Workflow et Bibliothèque de scripts Bash/PowerShell prêts à l'emploi.
*   📚 **Biliothèque Hardware** : Aide au diagnostic matériel (codes bips BIOS) et survivalisme IT.

---

## 🛠️ Stack Technologique
<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white" alt="Markdown">
  <img src="https://img.shields.io/badge/GPLv3-gray?style=for-the-badge" alt="GPLv3">
</p>

---

## 👨‍💻 Pour les Développeurs (Quick Start)

Si vous souhaitez contribuer ou compiler le projet localement :

1. **Configuration de l'environnement** :
   ```bash
   make setup
   ```
2. **Installation des dépendances** :
   ```bash
   make get
   ```
3. **Lancer en mode debug** :
   ```bash
   flutter run
   ```
4. **Compilation multi-plateforme** :
   ```bash
   make build-all
   ```

Pour plus de détails sur la signature des binaires, consultez [SIGNING.md](./SIGNING.md).

---

## 🤝 Soutenu par l'Association TUTODECODE (ESS)

TUTODECODE est le projet phare de l'Association TUTODECODE (Organisme d'intérêt général, SIREN : 102 763 133).

En tant qu'entité de l'Économie Sociale et Solidaire (ESS), notre mission est la diffusion gratuite du savoir technique. Nous garantissons une application :

🚫 Sans Tracking : Aucun analytics, aucune collecte de données.

🔒 Souveraine : Vos données restent sur votre machine.

🌍 Accessible : Conçue pour fonctionner là où le réseau ne va pas.


## 🔐 Signature des binaires
La release CI signe maintenant les binaires Android, Windows, macOS, iOS et Linux.
Pour configurer les certificats/secrets GitHub Actions, voir [SIGNING.md](./SIGNING.md).

---
*Fait avec ❤️ par l'Association TUTODECODE — [www.tutodecode.org](https://www.tutodecode.org)*
