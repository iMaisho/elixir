# Best Practices

## Rappels

### Nomenclature

- Utiliser des **noms clairs, explicites et cohérents** pour les modules, les schémas et les variables.
- Les **modules** (ex : contexts, schemas) utilisent la **camel case** (`IntranetMessage`, `UserAccount`).
- Les **tables en base de données** et **routes** utilisent la **snake case** plurielle (`intranet_messages`, `user_accounts`).
- Les **fonctions** sont en **snake case** et doivent **décrire précisément leur action** (`list_intranet_messages`, `create_user`, `get_conversation_with_preload!`).
- Les **associations** (`has_many`, `belongs_to`) doivent **reprendre les noms exacts des modules liés**.

**Exemple concret** :
```elixir
schema "intranet_messages" do
  belongs_to :intranet_conversation, IntranetConversation
end
```

### Conventions de nomenclature avancées

#### Underscores `_`

On utilise un underscore seul `_` ou un nom de varable commençant par un underscore `_variable_name` pour une variable qui ne sera pas utilisée.

On peut également utiliser l'underscore pour nommer une fonction, ce qui fera qu'elle ne sera pas importée par défaut lors de l'import de son module.

```elixir
defmodule Example do
  def _wont_be_imported do
    :oops
  end
end

import Example
_wont_be_imported()
** (CompileError) iex:1: undefined function _wont_be_imported/0
```

Les fonctions ou macros dont le nom est entouré de double underscore (comme `__info__/1`, `__MODULE__/0`, etc.) ne sont pas juste une convention stylistique : **elles sont réservées pour le compilateur et le système d’exécution.**

Elles servent principalement à ajouter ou interroger des métadonnées sur un module à la compilation ou à l’exécution.

##### `__info__/1` : Obtenir les infos d’un module
Chaque module Elixir génère automatiquement une fonction `__info__/1`.

Tu peux l’utiliser pour demander différentes métadonnées sur ce module. Par exemple :
``` elixir
String.__info__(:functions)

# Renvoie :
[
  at: 2,
  capitalize: 1,
  chunk: 2,
  ...
]
```
👉 Ici, tu obtiens la liste des fonctions exportées par le module String, avec leur arité (nombre d’arguments).

##### Les 5 formes spéciales

Ces macros/fonctions sont utilisées à la compilation, notamment dans les macros, pour obtenir le contexte dans lequel le code est en train de se compiler.


- `__CALLER__/0`	Donne des infos sur l’appelant actuel d’une macro : nom du module, ligne, fichier, etc.
- `__ENV__/0`	Donne l’environnement de compilation courant (module, fonctions importées, etc.)
- `__MODULE__/0`	Renvoie le nom du module courant
- `__DIR__/0`	Renvoie le chemin du fichier courant
- `__STACKTRACE__/0`	Renvoie la stacktrace de l’exception en cours (à utiliser dans rescue)


#### Point d'exclamation `!`

En général lorsqu'on définit une fonction, on veut gérer les cas d'erreur pour pouvoir réagir en conséquence sur l'application (envoyer un message d'erreur ou autre..)

```elixir
case File.read(file) do
  {:ok, body} -> # do something with the `body`
  {:error, reason} -> # handle the error caused by `reason`
end
```

Cependant, quand on sait que l'erreur est improbable ou critique, on utilise `!`

```elixir
File.read!("file.txt")
"file contents"
File.read!("no_such_file.txt")
** (File.Error) could not read file no_such_file.txt: no such file or directory
```

Cela permet de lever une erreur plus explicite, là où l'exemple d'avant lèverait seulement une erreur de Pattern Matching `MatchError`


#### Point d'interrogation `?`

On utilise le point d'interrogation à la fin du nom d'une fonction qui retourne un `bool`

#### Préfixe `is_`

On l'utilise pour nommer notre fonction si elle est autorisée dans une **garde** (`guard clause`), une condition supplémentaire que tu peux ajouter à une clause de fonction ou de pattern matching pour affiner le comportement de la fonction.

```elixir
defmodule Test do
  def double(x) when is_integer(x), do: x * 2
  def double(x), do: x
end

Test.double(10) # => 20
Test.double("a") # => "a"
```

Dans une guard clause, on ne peux pas utiliser n’importe quelle fonction !
Seules certaines fonctions dites "pures" et sûres (souvent en termes de performances ou d'effets de bord) sont autorisées.

Ces fonctions :
- sont déterministes
- ne lèvent pas d’exception
- ne modifient rien
- sont très rapides (souvent directement intégrées dans la VM)

C’est pour cela que les fonctions valides en garde utilisent le préfixe `is_ `   pour suivre la convention Erlang et signaler qu’elles peuvent être utilisées dans une garde.


#### Noms spéciaux en Elixir

Certains noms ont une signification particulière en Elixir. Voici les cas les plus courants.



##### `length` et `size`

Lorsque vous voyez **`size`** dans le nom d'une fonction, cela signifie que l’opération s’exécute en **temps constant** (`O(1)`) car la taille est **stockée avec la structure de données**.

**Exemples** : `map_size/1`, `tuple_size/1`

Lorsque vous voyez **`length`**, l’opération s’exécute en **temps linéaire** (`O(n)`) car la structure de données doit être **parcourue entièrement**.

**Exemples** : `length/1`, `String.length/1`

👉 En résumé, les fonctions contenant `size` prennent **le même temps** peu importe la taille des données, tandis que celles avec `length` deviennent **plus lentes** à mesure que la structure grandit.


##### `get`, `fetch`, `fetch!`

Dans les structures de type clé-valeur, les fonctions `get`, `fetch` et `fetch!` ont des comportements bien définis :

- `get` renvoie la **valeur demandée** si elle existe, ou une **valeur par défaut** (par défaut : `nil`) si la clé est absente.
- `fetch` renvoie `{:ok, valeur}` si la clé existe, ou `:error` sinon.
- `fetch!` lève une **erreur** si la clé est absente, sinon elle renvoie la valeur.

**Exemples** :
`Map.get/2`, `Map.fetch/2`, `Map.fetch!/2`
`Keyword.get/2`, `Keyword.fetch/2`, `Keyword.fetch!/2`


##### `compare`

Une fonction `compare/2` doit retourner :

- `:lt` si le premier élément est inférieur au second,
- `:eq` s’ils sont équivalents,
- `:gt` si le premier est supérieur.

**Exemple** : `DateTime.compare/2`

Cette convention est importante car elle est utilisée notamment par des fonctions comme `Enum.sort/2`.


### mix format, mix credo, mix test

- **mix format**
  ➔ **Obligatoire** avant chaque commit.
  ➔ Reformate automatiquement le code pour garantir **une mise en forme standardisée** (indentation, espaces, retours à la ligne).

- **mix credo**
  ➔ **À exécuter régulièrement pendant le développement**.
  ➔ Détecte les problèmes de style, de structure et les risques techniques (ex : fonctions trop longues, duplication de code).
  ➔ Corriger les alertes importantes avant de merger ou livrer.

- **mix test**
  ➔ Doc : https://hexdocs.pm/mix/Mix.Tasks.Test.html
  ➔ **À exécuter systématiquement avant chaque commit**.
  ➔ Vérifie que **l’ensemble du projet reste fonctionnel** après chaque modification.
  ➔ Aucun commit ne doit être fait si des tests échouent.

**Enchaînement standard conseillé** avant toute validation :
```bash
mix format
mix credo --strict
mix test
```

## Workflow Frixel

Lorsque vous souhaitez réaliser une nouvelle fonctionnalité (ou une nouvelle tâche) sur un projet, vous devez respecter les étapes suivantes :

### **I - Créer le ticket JIRA associé**

[**JIRA**](https://cristal-flow.atlassian.net/jira) est un outil de gestion de projet et de suivi de bugs. Beaucoup utilisé en agile, JIRA permet de faciliter la planification de tâches. Nous l’utilisons afin de permettre un suivi constant et maitrisé des différentes tâches (tech ou non tech) à réaliser sur un projet spécifique.

Le tableau de bord d’un projet JIRA contient des tickets présents dans des colonnes différentes, qui spécifient le niveau d’avancement des tâches. Un ticket JIRA doit correspondre soit à une tâche (nouvelle fonctionnalité, tâche terchnique, une refactorisatonn de code, ect) ou à un bug/incident à corriger.

### **II - Créé la branche GIT pour commencer le développement de la feature**

On créé une nouvelle branche toujours à partir de la branche principale (en général nommée `master` ou `main`) afin de s’assurer d’embarquement les derniers changements récemment publiés sur la dernière version du projet. Voici la commande pour créer une nouvelle branche :

`git checkout -b nom-de-la-feature-à-implémenter`

Une fois la branche créée, vous pouvez commencer votre implémentation.

⚠️ **Important à savoir** : Voici les 10 commandements de la bonne gestion d’une branche lors de l’implémentation d’une nouvelle fonctionnalité ou tout autre tâche technique :

- Le nom de ta branche doit idéalement porter le même nom que le ticket JIRA associé
- Le nom de ma branche doit contenir le numéro de référence du ticket JIRA associé à la tâche concernée
- Le nom de mes commits doit contenir un mot clé qui définit la nature des changements apportés par la tâche que je souhaite effectué (respect de la [**nomenclature des commits**](https://www.notion.so/JF-TP-2-bonnes-pratiques-git-et-mise-en-place-d-une-CI-1764d1e5f33e80a7b3b6ec01c742bc61?pvs=21) mise en place par mon équipe)
- Jamais et au grand jamais je vais m’amuser à créer ma branche depuis une branche qui n’est pas considéré comme branche principale
- Je dois régulièrement pousser du code sur ma branche afin de faire des sauvegardes régulières de mon niveau d’avancement

- Ma branche doit toujours être à jour avec tous les changements qui arrivent sur la branche principale (en utilisant la commande [`git rebase`](https://www.notion.so/JF-TP-2-bonnes-pratiques-git-et-mise-en-place-d-une-CI-1764d1e5f33e80a7b3b6ec01c742bc61?pvs=21))
- Ma branche ne doit jamais avoir une durée de vie supérieur à 48h
- Ma branche doit être liée à une seule tâche
- Ma branche doit être liée à un seul ticket JIRA
- À bas les branches “’*j’y mets tout ce qui me passe par la tête*”

### **III - Implémentation de la feature**

Ici vous pouvez vous lancez dans la réalisation de votre tâche et faire des sauvegardes de façon régulière sur votre branche. Voici les trois commandes qui seront vos amis fidèles durant cette phase :

`git add fichier_1 fichier_2 ...`

`git commit -m "Message du commit"`

`git push`

### **IV - Création de la PR**

Une fois la fonctionnalité (ou tâche) terminée, il est temps de créer une “***pull request***” (**PR**) de son travail depuis la branche en cours vers la branche principale.

***On fait une PR afin de proposer aux membres de son équipe de faire une revue de code des changements (issues de la tâche sur laquelle on a travaillé) que l’on souhaite apporter sur le projet.***

**N.B**: *Tout se passe sur l’interface graphique de Github (Outils de versioning que nous utilisons)*

<aside>
💡

⚠️ **Avant de de créer sa PR, il faut toujours s’assurer que les commandes suivantes ne génèrent aucune erreur en local (Nous verrons plus tard à quoi elles servent)** ⚠️

`mix test`

`mix credo`

</aside>

**Quel format doit avoir le titre de ma PR ?**

Le titre de ma **PR** doit respecter le format suivant :

<aside>
💡

**`DF-322** **feat**(**mise en place d'un chat collaboratif**) - Création de rooms de chat`

**DF-322 : Numéro du ticket JIRA**

**feat : Type de tâche réalisée (Cf. Format “**[conventional commits](https://www.notion.so/JF-TP-2-bonnes-pratiques-git-et-mise-en-place-d-une-CI-1764d1e5f33e80a7b3b6ec01c742bc61?pvs=21)**” définis avec l’équipe)**

**mise en place… : Nom de la tâche effectuée**

**création de … : Détails de la tâche**

</aside>

**Ne pas oublier d’attribuer un reviewer à la PR que vous allez créer.**

### **V - Revue de code de la PR et Prise en compte des retours de la revue**

Une fois une PR ouverte :

- En tant que reviewer, vous pouvez faire des retours sur le code proposé
- En tant que créateur de la PR vous devez attendre de recevoir des retours proposés par la personne en charge de la revue de code.

***Les revues de code vont nous permettre de détecter en amont de la validation du code, des vulnérabilités ou erreurs de conception dans le but d’améliorer la qualité et maintenabilités du code source de notre projet.***

**N.B**: *Tout se passe sur l’interface graphique de Github (Outils de versioning que nous utilisons)*

### **VII - Validation de la PR**

Une fois que les retours (si ils y en a) seront pris en compte, en tant que reviewer , vous pouvez valider la PR.

***La valide de la PR indique que le code examiné est propre et prêt à être merger sur la branche principale.***

**N.B**: *Tout se passe sur l’interface graphique Github (Outils de versioning que nous utilisons)*

### **VIII - Merger le code de la PR sur la branche principale**

Une fois la PR validée, vous (en tant que reviewer) êtes enfin prêt à merger le code source proposé vers la branche principale. Ce qu’il faut savoir avant de merger une PR :

<aside>
💡

1. ***Toujours penser à faire “un squash and merge”*** : Il faut éviter de polluer la branche principale avec tous les commits inutiles que vous avez poussé durant votre phase d’implémentation. En faisant un “***squash and merge***”, on s’assure d’agréger tous les commits de notre travail en un seul commit dont le nom doit être identique à celui du titre de la PR
2.  ***Vous devez merger sur la branche principale si et seulement si vous avez une pipeline verte***. **Pourquoi** ? Ceci permet d’éviter d’intégrer des régressions dans le code source de la branche principale.

⚰️ **Ceux qui vont s’amuser à valider et merger des PR qui ont des pipelines rouges seront traqués, retrouvés et ….** 🙂

</aside>
