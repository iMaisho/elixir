# Pipelines & GitHub Actions


## 🛠️ Qu’est-ce que **GitHub Actions** ?

**GitHub Actions** est une fonctionnalité intégrée à GitHub permettant d’automatiser des tâches liées au cycle de vie du développement logiciel. Cela repose sur des **workflows**, c’est-à-dire des scénarios d’automatisation déclenchés par des événements comme un `push`, une `pull request`, ou un `merge`.



## 🔁 Les **pipelines** : définition simple

Un **pipeline** est une chaîne d'étapes automatisées (ou "jobs") exécutées dans un certain ordre. C’est le cœur de l’intégration continue (**CI**) et du déploiement continu (**CD**).

Dans le contexte de **GitHub Actions**, un pipeline est défini via un **workflow** (fichier `.yml`) qui précise :
- **Quand** il se déclenche (événements : `push`, `pull_request`, `schedule`, etc.)
- **Sur quoi** il agit (répertoires, branches, etc.)
- **Quelles étapes** il exécute (tests, lint, build, déploiement...)


## 📂 Structure d’un workflow GitHub Actions (exemple simple)

Fichier : `.github/workflows/ci.yml`

```yaml
name: Elixir CI

on:
  push:
    branches: [ "master" ]
  pull_request:
    branches: [ "master" ]

permissions:
  contents: read

jobs:
  build:

    name: Build and test
    runs-on: ubuntu-22.04

    steps:
    - uses: actions/checkout@v4
    - name: Set up Elixir
      uses: erlef/setup-beam@61e01a43a562a89bfc54c7f9a378ff67b03e4a21 # v1.16.0
      with:
        elixir-version: '1.15.2' # [Required] Define the Elixir version
        otp-version: '26.0'      # [Required] Define the Erlang/OTP version
    - name: Restore dependencies cache
      uses: actions/cache@v3
      with:
        path: deps
        key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
        restore-keys: ${{ runner.os }}-mix-
    - name: Install dependencies
      run: mix deps.get
    - name: Run credo
      run: mix credo
```

## 🧩 Éléments clés d’un pipeline GitHub Actions

| Élément        | Description |
|----------------|-------------|
| `on`           | Déclencheur (ex: `push`, `pull_request`, `schedule`) |
| `if:`         | Conditions additionnelles de déclenchement du job (ex: `if: always()` permet de lancer le job même si il y a eu une erreur dans les jobs précédents)|
| `jobs`         | Ensemble de tâches à exécuter |
| `steps`        | Étapes d’un job (ex: `checkout`, `build`, `test`) |
| `uses:`        | Réutilisation d’**actions** existantes (officielles ou tierces) |
| `run:`         | Commande shell exécutée directement |
| `env:`         | Variables d’environnement pour les jobs |



## ✅ Cas d’usage typiques

- **Lint et tests automatisés à chaque push**
- **Build de l’application** (ex: Webpack, Babel…)
- **Déploiement** sur un serveur, une plateforme cloud (ex: Vercel, Firebase, AWS, etc.)
- **Analyse de code statique** (ESLint, SonarCloud)
- **Release automatisée** (tag + publication sur GitHub ou npm)


# Déployer une application web

## Configuration

AWS et OVH par exemple permettent de

On peut décider de configurer et le serveur et la BDD, ou utiliser d'autres outils qui nous fournissent directement ce dont on a besoin pour installer l'infrastructure (PAAS). Cela permet de se passer de la configuration OBS.

### Scalingo

Une application correspond à une instance de notre projet.
Bonnes pratiques : Un environnement de Dev, un environnement de pré-prod, un environnement de Prod

- Environnement de Dev : Fait pour être cassée, on peut toujours la redéployer à partir de la branche main, elle est là pour faire tous les tests à l'utilisation.

- Environnement de pré-prod : Isoprod (contient les données réelles de la prod)

- Environnement de prod : Notre bijou, auquel les utilisateurs se connectent. Donc faire très attention à ne pas la casser

On crée une **application** par déploiement.
On lie notre environnement de versionning (ici github) et on sélectionne le Repo qui sera déployé.

Ca vient créer une remote branch à partir de la branche de notre choix (en général main), c'est à partir de cela que notre app sera déployée.

On ajoute un addon pour générer la BDD.
