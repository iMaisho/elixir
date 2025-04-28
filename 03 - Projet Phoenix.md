# I. Création d'un projet Phoenix
## 1. Commande terminal utilisée

```bash
mix phx.new my_project --live
```

- `mix phx.new` : génère un nouveau projet Phoenix.
- `--live` : ajoute directement le support de **Phoenix LiveView**.

Selon les options sélectionnées, l'installation des dépendances front-end (`esbuild`, `tailwind`) est également configurée.



## 2. Fichiers créés automatiquement

Principaux éléments générés :

- `lib/my_project/` : logique métier (contexts, schemas, etc.).
- `lib/my_project_web/` : couche web (contrôleurs, LiveViews, templates).
- `config/` : configurations générales du projet.
- `priv/repo/migrations/` : migrations SQL pour la base de données.
- `assets/` : frontend (JavaScript, CSS avec Tailwind).
- `test/` : tests automatisés.
- Fichiers racines : `mix.exs` (gestion des dépendances), `README.md`, `.gitignore`.



## 3. Effet concret sur notre projet

- Le projet Phoenix est initialisé et prêt à être utilisé.
- Toute la structure est en place pour développer l'application côté métier et côté interface utilisateur.
- LiveView est disponible dès le départ pour construire des interfaces dynamiques sans écrire de JavaScript.



## 4. Relations internes

- `lib/my_project/` contient la **logique métier** (contexts, schemas, fonctions métiers).
- `lib/my_project_web/` regroupe tout ce qui est **lié à l'interface web** : gestion des requêtes HTTP, LiveViews, formulaires, templates.
- `config/` connecte les différentes couches du projet (application, base de données, serveur web).
- `priv/repo/migrations/` permet de gérer les évolutions de la structure de la base de données.


# II. Ajout du `docker-compose.yml`

## 1. Action réalisée

- Fichier `docker-compose.yml` ajouté **manuellement** à la racine du projet (commande possible : `touch docker-compose.yml`).




## 2. Contenu du fichier

- Il crée un conteneur **PostgreSQL** avec Docker :

```yaml
version: "3.8"

services:
  db:
    image: postgres:14.4
    restart: always
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWD}
      - POSTGRES_USER=${POSTGRES_USR}
    ports:
      - 5432:5432
    volumes:
      - db:/var/lib/postgresql/data

volumes:
  db:
    driver: local
```



## 4. Impact sur le projet

- **Ajout d'une base de données PostgreSQL** accessible en local (`localhost:5432`).
- Les données sont **sauvegardées** grâce au volume Docker.
- Les variables `POSTGRES_PASSWD` et `POSTGRES_USR` doivent être définies (`.env` ou directement dans l’environnement).



## 5. Lien avec Phoenix

- Le fichier `config/dev.exs` doit être configuré pour se connecter à cette base :

```elixir
config :my_project, MyProject.Repo,
  username: System.get_env("POSTGRES_USR"),
  password: System.get_env("POSTGRES_PASSWD"),
  database: System.get_env("POSTGRES_DBNAME"),
  hostname: System.get_env("POSTGRES_HOSTNAME"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

- Connexion via **Ecto (Repo)**.



## Résumé rapide

| Élément        | Détail |
|-|--|
| **Commande**   | Ajout manuel (`touch docker-compose.yml`) |
| **Fichier**    | `docker-compose.yml` |
| **Changement** | Mise en place d'un conteneur PostgreSQL |
| **Impact**     | Base de données disponible pour Phoenix |
| **Lien**       | Configurer `config/dev.exs` |




# III. Analyse du commit - Ajout de `credo` dans `mix.exs`

## 1. Commande terminal utilisée

Ajout de la dépendance suivante dans la fonction `deps/0` :

```elixir
{:credo, "~> 1.7", only: [:dev, :test], runtime: false}
```

Après ajout, il faut lancer :

```bash
mix deps.get
```
pour installer la dépendance.



## 2. Effet concret sur notre projet

- `credo` est un outil d'**analyse statique du code** pour Elixir.
- Il aide à détecter :
  - Les mauvaises pratiques
  - Les incohérences stylistiques
  - Les erreurs potentielles
- Il est configuré pour n’être utilisé **qu’en environnement de développement et de test** (`only: [:dev, :test]`).
- Il **n’est pas chargé au runtime**, ce qui veut dire **aucun impact en production** (`runtime: false`).



## 3. Relation avec les autres parties du projet

- `credo` n'est **pas directement lié** au fonctionnement métier de Phoenix ou Ecto.
- Il agit **lors de la phase de développement** pour **améliorer la qualité du code**.
- Il sera exécuté par la commande :

```bash
mix credo
```
qui analysera tout le projet et proposera des recommandations.


# IV. Scaffold complet d'une live : `IntranetConversation`

## 1. Commande terminal utilisée

```bash
mix phx.gen.live Chats IntranetConversation intranet_conversations conversation_type:string conversation_status:string
```

Puis :

```bash
mix ecto.migrate
```
pour appliquer la migration créée.



## 2. Fichiers concernés

- **Domaine métier** (Context + Schema) :
  - `lib/ig_intranet/chats.ex` → Context `Chats`
  - `lib/ig_intranet/chats/intranet_conversation.ex` → Schema `IntranetConversation`
- **Base de données** :
  - `priv/repo/migrations/20250210091152_create_intranet_conversations.exs` → Migration SQL
- **Interface utilisateur (LiveView)** :
  - `lib/ig_intranet_web/live/intranet_conversation_live/form_component.ex`
  - `lib/ig_intranet_web/live/intranet_conversation_live/index.ex`
  - `lib/ig_intranet_web/live/intranet_conversation_live/show.ex`
  - `lib/ig_intranet_web/live/intranet_conversation_live/index.html.heex`
  - `lib/ig_intranet_web/live/intranet_conversation_live/show.html.heex`
- **Routeur** :
  - `lib/ig_intranet_web/router.ex` → Ajout des routes LiveView `/intranet_conversations`
- **Tests générés** :
  - `test/ig_intranet/chats_test.exs`
  - `test/ig_intranet_web/live/intranet_conversation_live_test.exs`
  - `test/support/fixtures/chats_fixtures.ex`



## 3. Effet concret sur notre projet

- **Base de données** :
  - Une nouvelle table `intranet_conversations` est créée avec deux colonnes : `conversation_type` et `conversation_status`, plus les timestamps.

- **Code métier (Context + Schema)** :
  - `Chats` devient le point d'entrée pour manipuler des `IntranetConversation` (listage, création, mise à jour, suppression).
  - `IntranetConversation` décrit la structure d'une conversation.

- **Interface utilisateur** :
  - **Index LiveView** pour lister, éditer, supprimer.
  - **FormComponent LiveView** pour le formulaire de création/édition.
  - **Show LiveView** pour afficher les détails d'une conversation.
  - Utilisation des composants LiveView pour naviguer sans recharger la page.

- **Tests** :
  - Couverture testée : création, mise à jour, suppression, affichage de la ressource.
  - Fixtures automatiques pour générer des données de test (`chats_fixtures.ex`).

- **Routing** :
  - Les routes LiveView sont automatiquement ajoutées dans le `router.ex` pour `/intranet_conversations`.



## 4. Relation avec les autres parties du projet

- `Chats` centralise la logique métier des conversations, ce qui permet de **séparer** proprement la couche Web et la couche métier.
- Le Schema `IntranetConversation` est **lié au Repo** et sera manipulé uniquement via le Context `Chats`.
- Les LiveViews interagissent exclusivement avec les fonctions du Context, jamais directement avec Repo.



## Vue rapide par fichier principal

| Fichier                                 | Rôle |
|--||
| `chats.ex`                              | Fournit API métier (`list`, `create`, `update`, `delete`) |
| `intranet_conversation.ex`              | Définit la structure d'une conversation |
| `form_component.ex`                     | Formulaire pour créer/modifier |
| `index.ex` + `index.html.heex`           | Liste, édition, suppression |
| `show.ex` + `show.html.heex`             | Détail d'une conversation |
| `router.ex`                             | Ajoute les routes LiveView |
| `migration create_intranet_conversations.exs` | Crée la table SQL |
| `tests/`                                | Vérifie toutes les opérations sur les conversations |



## Effet global de ce commit

- **Nouveau module métier complet** autour des "Intranet Conversations".
- **CRUD LiveView fonctionnel** : créer, modifier, lister, voir et supprimer les conversations en temps réel.
- **Tests automatiques** pour sécuriser l’évolution future du code.

Ok, ce que tu me montres ici, c'est une **modification du schema `IntranetConversation`** pour **passer certains champs (`conversation_type` et `conversation_status`) de simples strings à des enums Ecto**.

Analysons ça proprement.



# V. Utilisation d'`Ecto.Enum` pour préciser les valeurs autorisées dans la table

## 1. Commande terminal utilisée

Aucune commande automatique ici.
C’est une **modification manuelle** du fichier `lib/ig_intranet/chats/intranet_conversation.ex`.

Avant :
```elixir
field :conversation_type, :string
field :conversation_status, :string
```

Après :
```elixir
field :conversation_type, Ecto.Enum, values: [:public, :private]
field :conversation_status, Ecto.Enum, values: [:active, :archived]
```



## 2. Effet concret sur notre projet

- **conversation_type** est maintenant limité **strictement** aux valeurs `:public` ou `:private`.
- **conversation_status** est limité aux valeurs `:active` ou `:archived`.
- En base de données, Ecto stockera ça **comme des strings** (`"public"`, `"private"`, `"active"`, `"archived"`), **mais dans Elixir**, on les manipulera sous forme d'**atoms** (`:public`, `:private`, etc.).
- Cela ajoute une **protection automatique** contre toute valeur invalide lors de l'insertion ou de la mise à jour.



## 3. Relation avec les autres parties du projet

- **Formulaires LiveView** devront envoyer les bonnes valeurs (`"public"`, `"private"`, etc.).
- Les **validations dans le changeset** deviennent **automatiques** : plus besoin de `validate_inclusion/3` manuellement !
- Les tests devront fournir les valeurs autorisées (`:public`, `:private`, etc.) dans les attributs des fixtures ou des formulaires.

Parfait, je vois exactement ce qui a été modifié dans ce commit.

Voici l'analyse précise :



# VI. Modification du formulaire pour utiliser des `<select>`

## 1. Commande terminal utilisée

Modification **manuelle** du fichier :

- `lib/ig_intranet_web/live/intranet_conversation_live/form_component.ex`


- **Avant** :
  Les champs `conversation_type` et `conversation_status` étaient des **inputs texte libres** :
  ```elixir
  <.input field={@form[:conversation_type]} type="text" label="Conversation type" />
  <.input field={@form[:conversation_status]} type="text" label="Conversation status" />
  ```

- **Après** :
  Ils sont remplacés par des **menus déroulants (`select`)** avec options fixes :
  ```elixir
  <.input
    field={@form[:conversation_type]}
    type="select"
    options={[:public, :private]}
    label="Conversation type"
  />
  <.input
    field={@form[:conversation_status]}
    type="select"
    options={[:active, :archived]}
    label="Conversation status"
  />
  ```


## 2. Effet concret sur notre projet

- **Interface utilisateur** :
  - Au lieu de laisser l’utilisateur écrire librement `"public"`, `"private"`, `"active"`, `"archived"`,
    il **choisit maintenant parmi des valeurs prédéfinies** via un menu déroulant.
  - Cela **réduit les erreurs** et **garantit** que les valeurs envoyées au serveur sont valides.

- **Relation avec l'utilisation d'Ecto.Enum** :
  - Cette modification complète logiquement l’introduction d’`Ecto.Enum` dans le schema.
  - **Coïncidence stricte** entre ce que propose l'interface et ce que le schema autorise.

Parfait, voyons précisément ce que cela signifie et ce que ça implique :



# Bonus : Best Practice à la fin de l'ajout d'une feature : `mix format`, `mix credo`, `mix test`



## 1. Commandes terminal utilisées

### a. `mix format`

```bash
mix format
```

- **Action** : Reformate tout le code du projet selon les règles de style officielles d'Elixir (indentation, espaces, retours à la ligne, etc.).
- **Effet** :
  - Uniformise la présentation du code source.
  - Corrige automatiquement les petites erreurs de style.
  - Facilite la lecture et la maintenance du code.

**Impact** :
Aucune modification fonctionnelle du code, seulement du **formatage**.



### b. `mix credo`

```bash
mix credo
```

- **Action** : Lance **Credo**, l'outil d'analyse statique du code.
- **Effet** :
  - Inspecte tout le projet pour relever :
    - Les problèmes de style (ex: nommage de variables, fonctions trop longues, etc.)
    - Les problèmes de conception potentiels (ex: duplication de code, logique trop complexe)
  - Propose des **améliorations** sous forme de conseils.

**Impact** :
Ne modifie pas le code automatiquement.
C’est un **rapport** qui sert à détecter les points d'amélioration.



### c. `mix test`

```bash
mix test
```

- **Action** : Exécute **l'intégralité des tests automatisés** du projet.
- **Effet** :
  - Vérifie que toutes les fonctionnalités existantes fonctionnent comme attendu.
  - Permet de s'assurer que les dernières modifications n'ont **rien cassé**.
  - Les tests sont ceux présents dans les dossiers `test/`, par exemple :
    - `chats_test.exs`
    - `intranet_conversation_live_test.exs`

**Impact** :
Permet de garantir que notre projet est **stabilisé** après les derniers changements.



## 2. Effet concret sur notre projet

- **mix format** : Code propre, conforme aux standards Elixir.
- **mix credo** : Qualité du code vérifiée (et potentiellement des recommandations pour continuer à l'améliorer).
- **mix test** : Projet testé avec succès, ce qui valide que la création et la modification de `IntranetConversation` fonctionnent.


Parfait, merci pour la précision.
Donc en fait : **ce commit ne créait pas juste les schemas + migration, mais aussi toute la partie LiveView pour gérer les `IntranetMessage`**.
C'est encore plus intéressant !

On ajuste donc l'analyse complète :


# VII. Relations entre les LiveView `Conversation` & `Message`



## 1. Création de la LiveView `Message`

De la même façon qu'on a créé nos convesations, on génère les fichiers liés à la Live Messages grâce à une commande similaire.

```bash
mix phx.gen.live Chats IntranetMessage intranet_messages message_body:text intranet_conversation_id:references:intranet_conversations
```

Puis :

```bash
mix ecto.migrate
```


## 2. Ajouts dans le fichier `intranet_conversation.ex`

- Import d'un alias :
  ```elixir
  alias IgIntranet.Chats.IntranetMessage
  ```

- Déclaration d'une relation :
  ```elixir
  has_many :intranet_messages, IntranetMessage
  ```

**Effet** :
Permet de dire qu'une `IntranetConversation` **possède plusieurs** `IntranetMessages`.



## 3. Ajouts dans le fichier `intranet_message.ex`

- Import d'un alias :
  ```elixir
  alias IgIntranet.Chats.IntranetConversation
  ```

- Déclaration d'une relation :
  ```elixir
  belongs_to :intranet_conversation, IntranetConversation
  ```

- **Modification du changeset** (important) :
  ```elixir
  |> cast(attrs, [:message_body, :intranet_conversation_id])
  |> validate_required([:message_bod, :intranet_conversation_id])
  ```


## 4. Ajouts dans la migration `create_intranet_messages.exs`

- Ajout du champ de clé étrangère :
  ```elixir
  add :intranet_conversation_id, references(:intranet_conversations, on_delete: :nothing)
  ```

- Ajout de l'index sur cette clé :
  ```elixir
  create index(:intranet_messages, [:intranet_conversation_id])
  ```


Parfait, on reste **très concentrés** ici :
Tu m’as demandé d’analyser **uniquement ce qui concerne l’ajout de la relation entre `IntranetConversation` et `IntranetMessage` dans les LiveViews**.
Pas de blabla sur LiveView général, pas d’analyse de tout : **seulement la gestion de la relation**.

Allons-y :



# IX. Ajout de la **relation conversation → message** dans les LiveViews



## 1. Contexte

Avant ce commit :
- Les messages (`IntranetMessage`) étaient indépendants des conversations (`IntranetConversation`) dans les formulaires et l'affichage.

Après ce commit :
- **Chaque message est relié visuellement à une conversation** dans tous les écrans (index, show, form).



## 2. Ajouts exacts réalisés

### a) Chargement et association côté **context (`Chats`)**

Ajout de plusieurs fonctions dans `lib/ig_intranet/chats.ex`.

En `Ecto`, `preload` sert à charger les associations liées (comme has_many, belongs_to, etc.) immédiatement après une requête principale.
Cela permet d'avoir toutes les données nécessaires disponibles d'un coup (`O(2)`), sans déclencher de nouvelles requêtes lorsque l'on accède aux relations (`O(n+1)`), améliorant ainsi à la fois la performance et la simplicité du code.

- **Lister les conversations avec leurs messages préchargés** :
  ```elixir
  def list_intranet_conversation_with_preload do
    Repo.all(IntranetConversation)
    |> Repo.preload(:intranet_messages)
  end
  ```

- **Lister les messages avec leur conversation préchargée** :
  ```elixir
  def list_intranet_message_with_preload do
    Repo.all(IntranetMessage)
    |> Repo.preload(:intranet_conversation)
  end
  ```

- **Récupérer un message avec sa conversation** :
  ```elixir
  def get_intranet_message_with_preload!(id) do
    Repo.get!(IntranetMessage, id)
    |> Repo.preload(:intranet_conversation)
  end
  ```

- **Précharger dynamiquement une conversation depuis un message** :
  ```elixir
  def preload_intranet_conversation(intranet_message) do
    Repo.preload(intranet_message, :intranet_conversation)
  end
  ```



### b) Modification de **l'interface utilisateur (LiveView)**

#### Dans le formulaire `form_component.ex`
- Ajout d'un `<select>` pour choisir à quelle conversation rattacher le message :
  ```elixir
  <.input
    field={@form[:intranet_conversation_id]}
    type="select"
    label="Conversation rattachée"
    options={@intranet_conversations}
  />
  ```

- Lors du **submit/save**, après création ou modification d’un message, **le message est rechargé avec son `intranet_conversation`** :

  ```elixir
  notify_parent({:saved, intranet_message |> Chats.preload_intranet_conversation()})
  ```

#### Dans `index.ex` et `index.html.heex`
- Chargement des messages **avec conversation préchargée** :
  ```elixir
  Chats.list_intranet_message_with_preload()
  ```

- Lors de l'édition ou de la suppression d'un message, utilisation de :
  ```elixir
  Chats.get_intranet_message_with_preload!(id)
  ```

- Affichage du champ conversation dans la table :

  ```elixir
  {:col :let={{_id, intranet_message}} label="Conversation rattachée"}
    {intranet_message.intranet_conversation && "#{intranet_message.intranet_conversation.id}"}
  ```

(affichage de l’ID de la conversation associée)

#### Dans `show.ex` et `show.html.heex`
- Même logique :
  - Charger avec `get_intranet_message_with_preload!`
  - Afficher l'ID de la conversation associée :
    ```elixir
    <:item title="Conversation rattachée">{@intranet_message.intranet_conversation.id}</:item>
    ```



## 3. Résultat fonctionnel

- Lorsqu'on crée ou modifie un message :
  - **Un champ permet de choisir** la conversation associée.
- Lorsqu'on liste ou affiche un message :
  - **On voit à quelle conversation** il appartient.
- Les données sont **chargées intelligemment** avec `preload` pour éviter les problèmes de N+1 query.



## Résumé rapide ultra concentré

| Action | Détail |
|--|--|
| Context | Ajout de `list_intranet_message_with_preload`, `get_intranet_message_with_preload!`, etc. |
| Formulaire | Sélection de `intranet_conversation_id` via un menu déroulant |
| Index / Show | Affichage de l'ID de la conversation rattachée |
| Préload | Utilisé pour éviter les requêtes multiples inefficaces |

# X. Affichage des messages dans la Live conversations en utilisant Elixir et nos fonctions de preload

Toutes les modifications ont été faites **manuellement** dans les fichiers `.ex` et `.heex`.

## 3. Ajouts précis et impact sur le projet

### a) `index.ex` (LiveView pour la liste des conversations)

- Modification du **montage initial (`mount/3`)** :
  - Avant : on listait les conversations **sans** charger les messages (`Chats.list_intranet_conversations()`).
  - Maintenant : on liste les conversations **avec leurs messages préchargés** (`Chats.list_intranet_conversation_with_preload()`).

- Modification de l’édition (`apply_action/3`) :
  - Avant : `Chats.get_intranet_conversation!(id)`
  - Maintenant : `Chats.get_intranet_conversation_with_preload!(id)`

**Effet** :
→ À chaque chargement ou édition, la conversation arrive **avec tous ses messages** directement accessibles.



### b) `index.html.heex` (HTML de la liste)

- Ajout d'une nouvelle **colonne** `"Messages associés"` dans la table :
  ```elixir
  <:col :let={{_id, intranet_conversation}} label="Messages associés">
    <ul>
      <%= for intranet_messages <- intranet_conversation.intranet_messages do %>
        <li>{intranet_messages.message_body}</li>
      <% end %>
    </ul>
  </:col>
  ```

**Effet** :
→ Dans la liste des conversations, **on voit sous chaque conversation tous ses messages** en liste.



### c) `show.ex` (LiveView pour l'affichage d'une conversation)

- Modification du chargement (`handle_params/3`) :
  - Avant : `Chats.get_intranet_conversation!(id)`
  - Maintenant : `Chats.get_intranet_conversation_with_preload!(id)`

**Effet** :
→ Quand on ouvre une conversation en détail, **on a directement tous les messages liés préchargés**.



### d) `show.html.heex` (HTML de l'affichage)

- Ajout d'un nouvel item dans la liste :
  ```elixir
  <:item title="Messages associés">
    <ul>
   <%= if intranet_conversation.intranet_messages != [] do %>
       <ul>
         <%= for intranet_messages <- intranet_conversation.intranet_messages do %>
           <li>{intranet_messages.message_body}</li>
         <% end %>
       </ul>
     <% else %>
       Aucun messages rattachés à cette conversation
     <% end %>
    </ul>
  </:item>
  ```

**Effet** :
→ Sur la page de détail d'une conversation, **on affiche aussi tous les messages associés** sous forme de liste, et on gère le cas où une conversation n'a pas encore de messages qui lui sont associés.



## 4. Résultat concret sur notre projet

- **Toutes les conversations** affichées dans les listes et détails **présentent leurs messages associés**.
- **Aucune nouvelle requête SQL** déclenchée au clic (grâce au preload fait au chargement).
- **Interface plus complète** : un utilisateur voit tout le contenu d'une conversation sans navigation supplémentaire.

Très bonne question : on entre ici dans un point **fondamental** en Phoenix LiveView, ce qu’on appelle parfois **la transmission du "state"** entre les différentes étapes de l’interface.

Je vais te faire un **topo clair, pas trop long, mais bien précis**, exactement comme tu veux :


# XI. 🔗 La chaîne logique de transmission de données en Phoenix LiveView



## 1. Le principe général

Quand on utilise LiveView (par exemple entre **Index** ➔ **Show**), **les données doivent être rechargées ou transmises correctement** à chaque changement de page ou d'action.

En LiveView, **on ne passe pas directement des structures Elixir d'une vue à l'autre** :
- **Chaque vue est indépendante**.
- **Chaque changement d'URL ou d'action** déclenche un événement (`handle_params/3`) dans la nouvelle LiveView.
- Ce sont **les `assigns` du socket** qui transportent **localement** les données dans la session LiveView courante.



## 2. La chaîne logique typique dans un projet Phoenix LiveView

Exemple : afficher une conversation détaillée après avoir cliqué sur une conversation dans la liste.

1. **Sur l'Index** (`index.ex`) :
   - On charge toutes les conversations avec preload (`list_intranet_conversation_with_preload`).
   - On "stream" les conversations dans le socket (`stream(socket, :intranet_conversations, ...)`).

2. **Sur clic sur une conversation** (par ex. lien Show) :
   - Le routeur modifie l'URL (`/intranet_conversations/:id`).
   - Cela déclenche `handle_params/3` dans la **Show LiveView**.

3. **Dans `handle_params/3` de Show** :
   - On **récupère l'ID** dans les paramètres.
   - On **refait une requête en base** (`get_intranet_conversation_with_preload!(id)`) pour récupérer **la bonne conversation**.
   - On **assign** cette conversation au `socket` pour que le template puisse l'afficher (`assign(:intranet_conversation, ...)`).

4. **Dans `show.html.heex`** :
   - On utilise `@intranet_conversation` pour afficher les détails et les messages associés.


Parfait, on continue dans notre méthode rigoureuse.
Voici l'analyse précise de ce que tu viens de m'envoyer :



# XII. Supression en cascade de nos éléments liés : `on_delete: :delete_all`

Dans la définition du `schema`, on ajoute :

Avant :
```elixir
has_many :intranet_messages, IntranetMessage
```

Par :
```elixir
has_many :intranet_messages, IntranetMessage, on_delete: :delete_all
```



## 1. Effet concret sur le projet

- Tu déclares que **quand une conversation est supprimée**, **tous les messages associés doivent être supprimés automatiquement** dans la base de données.
- `on_delete: :delete_all` transmet l'instruction jusqu'au niveau d'Ecto et, indirectement, à la base de données via la gestion d'Ecto associations.
- Cela évite :
  - Les **messages orphelins** qui resteraient en base sans conversation liée.
  - Les **erreurs de contraintes** à la suppression.



## 2. Suppression en BDD

**Attention** : pour que ce comportement fonctionne **vraiment au niveau de la base de données (PostgreSQL)**,
il faudrait aussi configurer la contrainte de clé étrangère `on_delete: :delete_all` dans ta **migration SQL** (optionnel selon besoin).

**Exemple dans la migration :**
```elixir
add :intranet_conversation_id, references(:intranet_conversations, on_delete: :delete_all)
```


# XIII. 📦 Topo sur les fixtures en Phoenix/Elixir



## 1. Qu’est-ce qu’une fixture ?

Une **fixture** est une **fonction utilitaire** qui sert à **préparer des données de test** rapidement et de manière fiable.
Elle te permet de **générer des entités** (ex : une conversation, un message) sans avoir à réécrire tout le temps les mêmes étapes dans tes tests.



## 2. Où sont-elles définies ?

- Les fixtures sont en général définies dans le dossier :
  ```
  test/support/fixtures/
  ```
- Tu y ranges des modules comme :
  - `ChatsFixtures`
  - `AccountsFixtures`
  - etc.



## 3. Comment ça fonctionne concrètement ?

Une fixture est **juste une fonction** qui :
- Prend éventuellement des **attributs personnalisés**.
- Applique des **valeurs par défaut** si nécessaire.
- Utilise le **context** pour créer la ressource en base (via une fonction comme `create_intranet_conversation/1`).
- Retourne **l'objet créé** (souvent une struct Elixir).



## 4. Exemple typique

**Fixture pour un `IntranetMessage` :**

```elixir
def intranet_message_fixture(attrs \\ %{}) do
  {:ok, intranet_message} =
    attrs
    |> Enum.into(%{
      message_body: "some message_body",
      intranet_conversation_id: some_conversation_id
    })
    |> IgIntranet.Chats.create_intranet_message()

  intranet_message
end
```

- Si on ne passe rien (`attrs \\ %{}`), la fixture crée un message avec des valeurs par défaut.
- Si on passe des attributs, elle les fusionne (`Enum.into/2`) avec les valeurs par défaut.



## 5. Pourquoi utiliser des fixtures ?

- **Facilite l'écriture de tests** : plus besoin de répéter comment créer une conversation ou un message.
- **Gagne du temps** : un simple appel comme `intranet_conversation_fixture()` et ta donnée est prête.
- **Centralise les valeurs de test** : si demain tu changes la structure, tu n’as qu’à corriger la fixture une seule fois.
- **Garantit la cohérence** : tes tests dépendent d’objets créés selon **la vraie logique métier**.


✅ Avec des bonnes fixtures, **tes tests deviennent plus rapides à écrire, plus robustes, et plus lisibles**.





# XIV. Ajout de la relation entre conversation et messages dans les tests


## 1. Ajouts et modifications précises

### a) Dans `chats_test.exs`

Avant :
- Les tests créaient un `IntranetMessage` sans se soucier de son `intranet_conversation_id`.

Après :
- Tous les tests qui manipulent un `IntranetMessage` sont **modifiés** pour **lui associer obligatoirement une `IntranetConversation` existante**.

Comment ?
- Introduction d’un `setup` qui crée une conversation avant chaque bloc de tests :
  ```elixir
  setup [:create_intranet_conversation]
  ```

- Modification de chaque test pour :
  - Utiliser `intranet_conversation.id` lors de la création du `intranet_message`.
  - Exemple :
    ```elixir
    intranet_message_fixture(intranet_conversation_id: intranet_conversation.id)
    ```

- Modifications apportées aux tests :
  - `list_intranet_messages/0`
  - `get_intranet_message!/1`
  - `create_intranet_message/1`
  - `update_intranet_message/2`
  - `delete_intranet_message/1`
  - `change_intranet_message/1`

**Effet** :
Tous les tests de `IntranetMessage` deviennent **réalistes**, car **un message sans conversation associée serait invalide** selon notre modèle actuel.



### b) Dans `chats_fixtures.ex`

Modification de la fonction `intranet_message_fixture/1` :

- Avant :
  - Génération d'un `message_body` sans se soucier de conversation.
- Après :
  - Vérification si `:intranet_conversation_id` est fourni, sinon création automatique d’une `IntranetConversation` :
    ```elixir
    intranet_conversation_id =
      attrs[:intranet_conversation_id] ||
        intranet_conversation_fixture(attrs[:intranet_conversation] || %{}).id
    ```

- Lors de la création du message :
  - Ajout automatique du champ `intranet_conversation_id`.

**Effet** :
Les fixtures génèrent maintenant **des messages liés à une conversation valide**, ce qui garantit la cohérence des tests.



## 2. Effet concret sur notre projet

- **Tous les tests unitaires du Context `Chats`** sont désormais **compatibles** avec la nouvelle structure métier qui impose que chaque message soit rattaché à une conversation.
- **Pas de crash**, **pas de validation échouée** à cause d'un `intranet_conversation_id` manquant.
- Le projet est **sécurisé au niveau des tests** et respecte la **cohérence métier**.
