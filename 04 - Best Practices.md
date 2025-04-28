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
  ➔ **À exécuter systématiquement avant chaque commit**.
  ➔ Vérifie que **l’ensemble du projet reste fonctionnel** après chaque modification.
  ➔ Aucun commit ne doit être fait si des tests échouent.

**Enchaînement standard conseillé** avant toute validation :
```bash
mix format
mix credo --strict
mix test
```
