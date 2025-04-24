https://hexdocs.pm/elixir/1.18.3/Kernel.html

# Programmation Fonctionnelle

- Pas de classe
- Données immutables : L'état ne change jamais, donc la donnée peut être facilement manipulée et distribuée dans l'application
- Pas de for loop : On doit utiliser la récursivité

# Elixir

Immutabilité des données = Scalable

Tolérance à l'erreur : Si on a un bug avec une donnée, le programme peut se réparer tout seul en récupérant un état précédent

## Match Operator `=` & Pattern Matching

Contrairement à la plupart des langages, `=` n'est pas un symbole d'assignation, mais un symbole d'égalité. La valeur 1 n'est pas assignée à `a`, mais `a = 1`, comme en maths.

```elixir
a = 1

a # 1

a == 1 # true

[a,a] == [1,1] # true

[a,a] == [1,2] # erreur
```

### Pin Operator `^`

```elixir
a = 1 # 1

a = 2 # 2

^a = 3 # erreur

4 = a # erreur
```

### Extraction de données grâce au pattern matching

```elixir
[first, second, third] = ["a","b","c"]
second # "b"
third # "c"
```

On peut ignorer des valeurs grâce à `_`

```elixir
[_, _, third] = ["a","b","c"]
seconde # undefined variable
third # "c"
```

## Les Processus

Contrairement aux processus d’un OS, les processus en Elixir (et Erlang) sont légers et isolés. Ils sont gérés par la VM BEAM, qui optimise leur exécution grâce à un système de planification préemptive.

Chaque processus Elixir a sa propre mémoire, son propre ID `PID` et ne partage pas d’état avec les autres (pas de variables globales).

La communication entre processus se fait par passage de messages (message passing) dans leurs `mailbox`, ce qui évite les problèmes de synchronisation et de concurrence.

La création et la destruction de processus grâce au mot clef `spawn` sont très rapides et peu coûteuses en mémoire , et sont exécutés en FIFO

## Les acteurs

Elixir repose sur le modèle d’acteurs, où chaque processus joue le rôle d’un acteur capable de :

- Recevoir des messages

- Modifier son état interne

- Envoyer des messages à d’autres processus

Les acteurs fonctionnent de manière asynchrone et ne bloquent pas l’exécution d’autres processus. Cela permet à Elixir de gérer des millions de processus simultanés.

# Démarrer un projet

`mix` pour éxecuter de l'Elixir

`mix phx.new nom_du_projet` pour créer un nouveau projet **Phoenix**

Les fichiers `exs` sont des scripts executables

Les fichiers `ex` sont les fichiers de compilation.

`iex nom_du_projet.ex` pour lancer la machine virtuelle (Interactive Elixir)

# Nomenclature

## Casing

`snake_case` pour les atomes, variables, noms de fonctions, noms de fichiers

`CamelCase` pour les noms de modules

## Underscores `_`

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

### `__info__/1` : Obtenir les infos d’un module
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

### Les 5 formes spéciales

Ces macros/fonctions sont utilisées à la compilation, notamment dans les macros, pour obtenir le contexte dans lequel le code est en train de se compiler.


- `__CALLER__/0`	Donne des infos sur l’appelant actuel d’une macro : nom du module, ligne, fichier, etc.
- `__ENV__/0`	Donne l’environnement de compilation courant (module, fonctions importées, etc.)
- `__MODULE__/0`	Renvoie le nom du module courant
- `__DIR__/0`	Renvoie le chemin du fichier courant
- `__STACKTRACE__/0`	Renvoie la stacktrace de l’exception en cours (à utiliser dans rescue)


## Point d'exclamation `!`

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


## Point d'interrogation `?`

On utilise le point d'interrogation à la fin du nom d'une fonction qui retourne un `bool`

## Préfixe `is_`

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


## Noms spéciaux en Elixir

Certains noms ont une signification particulière en Elixir. Voici les cas les plus courants.



### `length` et `size`

Lorsque vous voyez **`size`** dans le nom d'une fonction, cela signifie que l’opération s’exécute en **temps constant** (`O(1)`) car la taille est **stockée avec la structure de données**.

**Exemples** : `map_size/1`, `tuple_size/1`

Lorsque vous voyez **`length`**, l’opération s’exécute en **temps linéaire** (`O(n)`) car la structure de données doit être **parcourue entièrement**.

**Exemples** : `length/1`, `String.length/1`

👉 En résumé, les fonctions contenant `size` prennent **le même temps** peu importe la taille des données, tandis que celles avec `length` deviennent **plus lentes** à mesure que la structure grandit.


### `get`, `fetch`, `fetch!`

Dans les structures de type clé-valeur, les fonctions `get`, `fetch` et `fetch!` ont des comportements bien définis :

- `get` renvoie la **valeur demandée** si elle existe, ou une **valeur par défaut** (par défaut : `nil`) si la clé est absente.
- `fetch` renvoie `{:ok, valeur}` si la clé existe, ou `:error` sinon.
- `fetch!` lève une **erreur** si la clé est absente, sinon elle renvoie la valeur.

**Exemples** :
`Map.get/2`, `Map.fetch/2`, `Map.fetch!/2`
`Keyword.get/2`, `Keyword.fetch/2`, `Keyword.fetch!/2`


### `compare`

Une fonction `compare/2` doit retourner :

- `:lt` si le premier élément est inférieur au second,
- `:eq` s’ils sont équivalents,
- `:gt` si le premier est supérieur.

**Exemple** : `DateTime.compare/2`

Cette convention est importante car elle est utilisée notamment par des fonctions comme `Enum.sort/2`.

# Syntaxe de base

## Module `Hello World`

Un module en Elixir est une unité de code qui regroupe des fonctions, des macros et des définitions de types. Il permet d'organiser le code et de réutiliser les fonctionnalités.

`defmodule NomDuModule do`

```elixir
# Nom du module en PascalCase
defmodule Hello do
    # Les parenthèses sont facultatives, mais il vaut mieux les mettre
    # nomDeLaFonction en camelCase
    def world()
        # On utilise les double guillemets pour des chaînes de caractères
        IO.puts("Hello Elixir")
    end
end

Hello.world()
```

Puis, dans le terminal on peut utiliser `elixir hello.exs` pour le lancer, ce qui affichera `Hello Elixir`

### Compiler ce script

#### 1. En commande terminal

`elixirc hello.exs` permet de compiler notre fichier, ce qui créera un fichier `Elixir.Hello.beam`

#### 2. Dans le terminal interactif

`iex` pour lancer une instance de terminal elixir
`c "hello.exs"` pour le compiler
`r "hello.exs"` pour le recompiler

#### 3. En utilisant mix

On verra ça plus tard

## Module `Hello World` interactif

```elixir
defmodule Hello do
    def world(name)
        IO.puts("Hello #{name}")
    end
end
```

## Data Types

Les types de données sont immutables.

### Atome

Un atome est reconnaissable grâce à sa structure qui commence par `:`
Ex : `:some_name` ou `:"Some Name"`

Il s'agit d'une variable dont le nom du type est égale à la valeur de sa chaîne de caractères

`:world` est un atome, c'est équivalent à `world = "world"`

### Strings

Une chaîne de caractères est entourée par des doubles guillemets `"`

On peut utiliser `i` dans le terminal iex pour avoir des informations sur une donnée.

Une chaîne de caractères sera de type `BitString` et sa représentation pure sera sous la forme `<<97, 98, 99>>`

```elixir
"a" <> rest = "abc" # rest = "bc"

?a # 97 (valeur UTC-8)
```

`<>` permet de concaténer des chaines de caractères.
`<<>>` permet de travailler sur les valeurs UTC-8 des caractères

```elixir
<<"ab", rest::binary>> = "abcdef" # rest = "cdef"

<<head::binary-size(2), rest::binary >> # head = "ab"
```

### Charlist

Des simples guillements `'` indique à Elixir que l'on travaille avec une `liste de caractères`, ce qui aura un comportement différent.

Une liste de caractères sera de type `List` et sa représentation pure sera sous la forme `[97, 98, 99]`

`++` permet de concaténer des listes

### List

En Elixir, toutes les listes sont des listes liées.
Si je me souviens bien, cela veut dire que les éléments de la liste ne sont pas contigus et sont parsemés aléatoirement dans la mémoire, et que chaque élément est lié à l'adresse mémoire de l'élément suivant de la liste.

Cela signifie que l'accès au premier élément (head) est rapide, mais l'accès au dernier élément est coûteux, car il faut parcourir toute la liste.

C'est pour ça que les listes sont efficaces pour ajouter en tête (prepend), mais lentes pour ajouter/modifier un élément en fin de liste (append).

Cela veut également dire qu'on ne peut pas travailler directement avec les listes, avec `list[0]` par exemple.
On utilise la bibliothèque `Enum`.

**Les listes sont immuables, chaque opération crée une nouvelle liste au lieu de modifier l’ancienne.**

```elixir
list = [1, 2, 3]

list[0] # Erreur

Enum.at(list, 0) # 1

Enum.map(list, fn x -> x*2 end) # [2, 4, 6]

Enum.filter(list fn x -> x > 1 end) # [2, 3]
```

Une liste est séparée en deux parties, la tête (head) qui contient le premier élément de la liste et la queue (tail) qui contient le reste.
Les fonctions `hd(list)` et `tl(list)` permettent d'isoler ces deux parties de la liste.

On peut également utiliser le symbole `|` pour extraire simplement la tête et la queue de notre liste

```elixir
[h|t] = list # h = 1, t = [2,3]
```

C'est très utile pour la recursion car nos fonctions peuvent traiter à chaque fois la tête de la nouvelle liste jusqu'à arriver à une liste vide.

```elixir
defmodule MaListe do
  def somme([]), do: 0  # BaseCase : liste vide → retourne 0
  def somme([tete | queue]), do: tete + somme(queue)  # Additions récursives jusqu'à ce que la queue soit vide.
end

IO.puts MaListe.somme([1, 2, 3])  # 6 (1 + 2 + 3)
```

### Tuple

Un tuple est un groupe de données entouré par `{}`. C'est l'équivalent d'un Array dans la plupart des langages de programmation, les valeurs d'un tuple sont contigues dans la mémoire. Leur accès est rapide mais leur modification est coûteuse en termes de performance, en général on crée des tuples de 2 ou 3 éléments maximum.

Une utilisation très commune des tuples est le retour d'erreur :

`{:error, message} = {:error, "File not found"}`
`{:ok, message} = {:ok, "Status 200 ok"}`

Grâce au pattern matching, le message à droite sera lié à la variable message.

Grâce à `case`, on peut gérer notre vérification d'erreur :

```elixir
case File.read("inexistant.txt") do
  {:ok, contenu} -> IO.puts("Fichier lu avec succès: #{contenu}")
  {:error, raison} -> IO.puts("Erreur: #{raison}")
end
```

### Keyword List

Une keyword list est simplement une liste de tuples où :

- Les clés sont des atoms (:clé).
- Les valeurs peuvent être de n'importe quel type.

```elixir
options = [{:size, "large"}, {:color, "blue"}, {:price, 10}]
```

Cependant, quand une liste est composée uniquement de tuples `{:clé, valeur}`, Elixir autorise la syntaxe simplifiée `[clé: valeur]`.

```elixir
options = [size: "large", color: "blue", price: 10]
```

On utilise la bibliothèque `Keyword` pour manipuler les Keyword Lists.

```elixir
options = [size: "large", color: "blue"]

# get pour accéder à une valeur
IO.puts Keyword.get(options, :size)  # "large"

# put pour ajouter un tuple {:clé, valeur}
options = Keyword.put(options, :price, 10) # [size: "large", color: "blue", price: 10]

# delete pour supprimer un tuple {:clé, valeur}
options = Keyword.delete(options, :color) # [size: "large", price: 10]

# get_values pour voir toutes les valeurs d'une même clé
options = [size: "large", size: "small", color: "blue"]
IO.inspect Keyword.get_values(options, :size)  # ["large", "small"]
```

✅ Ordonnées → L’ordre d’insertion est préservé.
✅ Clés atomiques → Les clés doivent être des :atoms.
✅ Clés en double autorisées → Contrairement aux maps, une keyword list peut avoir plusieurs fois la même clé.
❌ Moins performantes que Map pour rechercher une valeur, car Elixir doit parcourir la liste.

### Map

Une map est une structure clé-valeur définie avec `%{}` où les clés sont uniques et peuvent être de n'importe quel type (`:atom`, `string`, `int`, etc.).

L'ordre n'est pas garanti mais l'accès aux données est plus rapide que les keyword lists.

Elles sont utilisées pour stocker et manipuler des données plutôt que pour passer des options de fonction.

```elixir
# Syntaxe classique
person = %{:name => "Alice", "age" => 30, :role => :admin}

# Syntaxe simplifiée si les clés sont des atomes
my_map = %{a: 1, b: 2, c: 3}
```

Grâce au pattern matching, il est très facile d'extraire des données d'une map.

```elixir
# Syntaxes possible si les clés sont des atomes
%{b: second} = my_map
second # 2
my_map.c # 3

# Syntaxe classique si les clés ne sont pas des atomes
%{"age" => age} = person
age # 30
```

On utilise la bibliothèque `Map` pour manipuler les maps.

```elixir
person = %{name: "Alice", age: 30}

# put pour ajouter ou mettre une clé à jour
person = Map.put(person, :role, :admin) # %{name: "Alice", age: 30, role: :admin}

# notation simplifiée pour mettre à jour une clé
person = %{person | age: 31}  # Mise à jour de l’âge


# delete pour supprimer une clé
person = Map.delete(person, :name) # %{age: 30, role: :admin}

# merge pour fusionner deux maps
map1 = %{a: 1, b: 2}
map2 = %{b: 3, c: 4}
merged = Map.merge(map1, map2)
merged # %{a: 1, b: 3, c: 4} (b est écrasé)

# has_keys? pour vérifier si la clé existe dans la map
IO.puts Map.has_key?(person, :age)  # true
IO.puts Map.has_key?(person, :height)  # false
```

### Struct

Les structs sont une extension des maps qui permettent de définir des structures de données avec des clés prédéfinies et des valeurs par défaut. Elles sont souvent utilisées pour représenter des entités comme des utilisateurs, des produits, etc.

Elles sont définies à l'intérieur d'un module, grâce à `defstruct`

```elixir
defmodule User do
  defstruct name: "Anonyme", age: 0, role: :user
end
```

`name`, `age` et `role` sont les champs de la struct. `"Anonyme"`, `0` et `:user` sont leurs valeurs par défaut.

```elixir
user = %User{name: "Alice", age: 30}
user # %User{name: "Alice", age: 30, role: :user}
```

✅ Définition stricte des champs → Impossible d’ajouter des clés non définies.
✅ Valeurs par défaut → Chaque champ peut avoir une valeur initiale.
✅ Plus sécurisée que les maps → Protection contre l'ajout involontaire de clés.
❌ Toujours liée à un module → Une struct est associée à un module spécifique.

Les structs sont immuables, donc toute modification crée une nouvelle struct.

```elixir
updated_user = %{user | age: 31}  # Mise à jour de l’âge
updated_user  # %User{name: "Alice", age: 31, role: :user}
```

🚨 Attention : L'opérateur `|` ne permet que de mettre à jour des clés existantes. Il est impossible d’ajouter une nouvelle clé avec cet opérateur.

Comme avec les maps, on peut accéder facilement aux valeurs d'une struct avec la notation `structName.keyName`

```elixir
updated_user.age # 31
```

## Flow Control

### case

Imaginons un module `Post` sur un forum ou autre site du type, qui serait définit par une struct

```elixir
defmodule Post do
    defstruct(
        id: nil,
        title: "",
        description: "",
        author: ""
    )
end
```

Puis, imaginons que notre User `Jules César` crée un nouveau post

```elixir
post1 = %Post{id: 1, title: "Mon nouveau post", author: "Jules César"}
```

On peut imaginer un comportement différent en fonction de l'auteur du post

```elixir
case post1 do
    %{author: "Michel"} -> "Michel a posté"
    # _ correspond à "N'importe quel nom d'auteur", tant qu'il est différent des cas établis précédemment
    _ -> "Nouveau post de %{post1.author}"
end
```

### cond

`cond` teste chaque expression jusqu'à ce que l'une d'elles soit true.

La première condition true exécute son bloc et retourne sa valeur.

Ligne de sécurité : Il est recommandé d’avoir true -> à la fin pour gérer les cas imprévus.

```elixir
age = 25

# Les conditions sont précisées dans le bloc
category = cond do
  age < 18 -> "Mineur"
  age < 65 -> "Adulte"
  true -> "Senior"
end

category # Adulte
```

✅ Évite les if/else imbriqués → Code plus clair et lisible.
✅ Permet plusieurs vérifications → Utile pour des règles complexes.
✅ Plus flexible que case → case est limité au pattern matching exact.
❌ Erreur si aucune condition n’est true → Toujours prévoir un true -> en dernier recours.

On peut combiner les conditions grâce à `and` pour des exemples un peu plus complexes

```elixir
temperature = 35
humidité = 80

alert = cond do
  temperature > 40 -> "Alerte : Canicule !"
  temperature > 30 and humidité > 70 -> "Attention : Chaleur et humidité élevées"
  temperature < 0 -> "Alerte : Grand froid !"
  true -> "Météo normale"
end

alert  # "Attention : Chaleur et humidité élevées"

```

# If/Else

Si on a qu'une seule condition à vérifier, on peut simplement utiliser if/else

```elixir
if condition do
    ...
else
    ...
end
```

## MIX

`mix` est **l’outil de gestion de projet** en Elixir. Il facilite la création, la compilation, la gestion des dépendances, les tests et bien plus encore. C'est un peu l'équivalent de `npm` pour JavaScript ou `cargo` pour Rust.

---

#### 📌 **1. Créer un projet avec `mix`**

```sh
mix new mon_projet
```

🎯 **Cela génère :**
✔ Un dossier avec une structure de base.
✔ Un fichier `mix.exs` qui contient les infos du projet.
✔ Un module principal dans `lib/mon_projet.ex`.

---

#### 📦 **2. Ajouter et gérer des dépendances**

Les dépendances sont déclarées dans `mix.exs`, dans la fonction `deps/0` :

```elixir
defp deps do
  [
    {:httpoison, "~> 1.8"},
    {:jason, "~> 1.2"}
  ]
end
```

Puis, on installe les dépendances avec :

```sh
mix deps.get
```

#### ⚡ **3. Compiler le projet**

```sh
mix compile
```

💡 Elixir ne recompile que ce qui a changé pour optimiser la vitesse.

#### 🧪 **4. Exécuter les tests**

Les tests sont dans `test/`. Pour les lancer :

```sh
mix test
```

✔ `ExUnit` est le framework de test intégré à Elixir.
✔ On peut exécuter un test précis avec `mix test test/mon_test.exs:42`.

---

#### 🏃 **5. Lancer un script interactif (`iex`) avec le contexte du projet**

```sh
iex -S mix
```

Cela charge automatiquement les modules du projet dans une session interactive.

---

#### 📂 **6. Générer un module et ses tests**

Avec `mix`, on peut générer des modules avec leurs fichiers associés :

```sh
mix new mon_projet --module MonModule
```

On peut aussi générer un module spécifique avec :

```sh
mix gen.module MonModule
```

---

#### 🎯 **7. Quelques commandes utiles**

| Commande                | Description                                              |
| ----------------------- | -------------------------------------------------------- |
| `mix format`            | Formate le code selon les conventions Elixir             |
| `mix run script.exs`    | Exécute un fichier Elixir                                |
| `mix deps.update --all` | Met à jour toutes les dépendances                        |
| `mix hex.info`          | Affiche les infos sur Hex, le gestionnaire de paquets    |
| `mix release`           | Crée un binaire exécutable pour déployer une application |

---

#### 🔥 **Résumé**

- `mix` facilite la **gestion de projet**, les **dépendances**, la **compilation** et les **tests**.
- Il permet d’exécuter une **session interactive avec `iex`** et le contexte du projet.
- C’est un outil **essentiel** pour tout développeur Elixir.

### Recursivité

#### Print récursif

Voici un exemple simple qui écrira tous les chiffres jusqu'à de n à 1

```elixir
defmodule Tutorials.Recursion.PrintDigits do
  # Base Case
  def upTo(0) do
    :ok # return est implicite, car c'est la dernière ligne de notre fonction
  end

  def upTo(number) do
    IO.puts(number)
    upTo(number - 1)
  end

end
```

On peut simplifier le base case pour qu'il ne tienne que sur une ligne, car il n'a qu'une valeur de retour

```elixir
def upTo(0), do: :ok
```

Si l'on souhaite inverser l'ordre de la récursion, et afficher les nombres de 1 à n, il suffit d'inverser les deux lignes de code dans notre fonction.

```elixir
  def upTo(number) do
    upTo(number - 1)
    IO.puts(number)
  end
```

Dans ce cas, le `print` (IO.puts) sera exécuté dans la **phase de retour** de la récursion : c'est la `Head Recursion`

Dans le cas précédent, il était exécuté dans la **phase d'ascension** de la récursion, c'est la `Tail Recursion`

#### Addition récursive

```elixir
defmodule Tutorials.Recursion.AddDigits do
  def addTo(0), do: 0

  def addTo(number) do
    number + addTo(number - 1)
  end

end
```

Cette simple version est `Head Recursive`. Comment faire si on voulait faire sa version `Tail` ?

```elixir
# Définition de la fonction, avec acc qui prend 0 en valeur par défaut
def addToTail(num, acc \\ 0)
# Base Case
def addToTail(0, acc), do: acc
# Tail Recursive
def addToTail(num, acc) do: addToTail(num - 1, acc + num)
```

La version `Tail Recursive` est moins coûteuse en mémoire, et réutilise la même stack à chaque nouvelle itération. Il faut donc la privilégier.

![image](https://github.com/iMaisho/elixir/blob/main/assets/head_tail_recursion.png?raw=true)

#### Exemple supplémentaire

Un autre exemple qui permet d'inverser le nombre fourni en entrée, en Tail Recursion

```elixir
# reverse(12345) -> 54321
defmodule Tutorials.Recursion.ReverseDigits do
  def reverse(num, acc \\ 0)
  def reverse(0, acc), do: acc
  def reverse(num, acc) do
    new_num = div(num, 10)
    new_acc = acc * 10 + rem(num, 10)
    reverse(new_num, new_acc)
  end
end
```

#### Documenter un module

On documente notre module juste en dessous de sa définition, grâce à différents mots clés :

##### @moduledoc

Ici, on vient faire un sommaire de nos différentes fonctions contenues dans ce module.

```elixir
defmodule Tutorials.Lists do
  @moduledoc """
  Sommaire des fonctions :

  1. sum
  """
```

##### @doc

Ensuite, on vient décrire nos fonctions, en utilisant `@doc` au dessus de chacune d'elle

```elixir
  @doc """
  Retourne la somme d'une liste de nombres.
  """
```

##### @spec
Enfin, on vient préciser les types de données que traite et renvoie notre fonction grâce à `@spec`

```elixir
@spec sum(list(number())) :: number()
```
### for

### with

# Mix - Tuto

# Mix - Stats Project
